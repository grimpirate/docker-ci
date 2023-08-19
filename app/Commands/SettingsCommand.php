<?php

namespace App\Commands;

use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;

class SettingsCommand extends BaseCommand
{
	protected $group = 'Setup';

	protected $name = 'setup:initial';

	protected $description = 'Initializes assorted configuration values';

	protected $usage = 'setup:initial';

	public function run(array $params)
	{
		CLI::write('Running custom setup...');

		helper('setting');

		setting('Session.driver', 'CodeIgniter\Session\Handlers\DatabaseHandler');
		setting('Session.savePath', 'ci_sessions');
		setting('Session.matchIP', 'true');

		setting('App.indexPage', '');
		setting('App.appTimezone', 'America/New_York');
		setting('App.baseURL', 'http://localhost');

		CLI::write('Custom setup complete.');
	}
}