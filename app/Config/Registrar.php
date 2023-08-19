<?php

namespace Config;

class Registrar
{
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
}