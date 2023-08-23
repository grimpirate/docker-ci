<?php

namespace Config;

class Registrar
{
	public static function Filters(): array
	{
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
				'username' => $_ENV['docker_db_user'],
				'password' => $_ENV['docker_db_pass'],
				'database' => $_ENV['docker_db_name']
			]
		];
	}

	public static function App(): array
	{
		return [
			'indexPage' => '',
			'appTimezone' => $_ENV['docker_tz_country'] . '/' . $_ENV['docker_tz_city'],
			'baseURL' => $_ENV['docker_ci_baseurl']
		];
	}

	public static function Session(): array
	{
		return [
			'driver' => \CodeIgniter\Session\Handlers\DatabaseHandler::class,
			'savePath' => $_ENV['docker_db_sessions'],
			'matchIP' => true
		];
	}
}