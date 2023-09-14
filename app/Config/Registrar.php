<?php

namespace Config;

use CodeIgniter\Shield\Authentication\Passwords;

class Registrar
{
	public static function Validation(): array
	{
		// Disables username validation on Shield registration
		return [
			'registration' => [
				'email' => [
					'label' => 'Auth.email',
					'rules' => 'required|max_length[254]|valid_email|is_unique[auth_identities.secret]'
				],
				'password' => [
					'label'  => 'Auth.password',
					'rules'  => 'required|' . Passwords::getMaxLengthRule() . '|strong_password[]',
					'errors' => [
						'max_byte' => 'Auth.errorPasswordTooLongBytes'
					]
				],
				'password_confirm' => [
					'label' => 'Auth.passwordConfirm',
					'rules' => 'required|matches[password]'
				]
			]
		];
	}

	public static function Auth(): array
	{
		// Custom register form view
		return [
			'views' => [
				'register' => '\App\Views\register.php'
			]
		];
	}

	public static function Filters(): array
	{
		// Disables CodeIgniter4 toolbar in development mode
		return [
			'globals' => [
				'after' => [
					//'toolbar'
				]
			]
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
			'baseURL' => $_ENV['docker.ci_baseurl']
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