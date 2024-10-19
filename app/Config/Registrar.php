<?php

namespace Config;

use CodeIgniter\Shield\Authentication\Passwords;

class Registrar
{
	public static function Email(): array
	{
		// Required for spark migration to proceed successfully
		return [
			'fromEmail' => 'anonym@us.com',
			'fromName' => 'anonym@us',
		];
	}

	public static function Auth(): array
	{
		return [
			// Custom register form view
			'views' => [
				'register' => '\App\Views\register.php'
			],
			// Disables username validation on Shield registration
			'usernameValidationRules' => [
				'rules' => [
					'permit_empty',
				],
			],
		];
	}

	public static function Filters(): array
	{
		return [
			// Protects all site pages
			'globals' => [
				'before' => [
					'session' => [
						'except' => [
							'login*',
							'register',
							'auth/a/*'
						]
					]
				]
			],
			// Disable the toolbar
			'required' => [
				'after' => [
					'pagecache',   // Web Page Caching
					'performance', // Performance Metrics
					//'toolbar',     // Debug Toolbar
				],
			],
		];
	}

	public static function Database(): array
	{
		return [
			'default' => [
				'username' => $_ENV['docker.db_user'],
				'password' => $_ENV['docker.db_pass'],
				'database' => $_ENV['docker.db_name']
			]
		];
	}

	public static function App(): array
	{
		return [
			'indexPage' => '',
			'appTimezone' => $_ENV['docker.tz_country'] . '/' . $_ENV['docker.tz_city'],
			'baseURL' => $_ENV['docker.ci_baseurl'],
			'defaultLocale' => 'en',
			'negotiateLocale' => true,
			'supportedLocales' => ['en'],
		];
	}

	public static function Session(): array
	{
		return [
			'driver' => \CodeIgniter\Session\Handlers\DatabaseHandler::class,
			'savePath' => $_ENV['docker.db_sessions'],
			'matchIP' => true
		];
	}
}