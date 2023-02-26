<?php

namespace Config;

class Registrar
{
    public static function Database(): array
    {
        return [
            'default' => [
                'DBDriver' => 'SQLite3',
                'database' => 'sub.db'
            ]
        ];
    }

    public static function App(): array
    {
        return [
            'indexPage' => '',
            'appTimezone' => 'America/New_York',
            'baseURL' => 'http://localhost'
        ];
    }

    public static function Filters(): array
    {
        return ['globals' => ['before' => ['session' => ['except' => ['login*', 'register', 'auth/a/*']]]]];
    }
}
