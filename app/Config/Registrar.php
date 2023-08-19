<?php

namespace Config;

class Registrar
{
	public static function Database(): array
	{
		return [
			'default' => [
				'username' => 'username',
				'password' => 'password',
				'database' => 'codeigniter4'
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