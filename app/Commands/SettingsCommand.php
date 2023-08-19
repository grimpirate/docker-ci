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
		setting('Session.savePath', $_ENV['docker_db_sessions']);
		setting('Session.matchIP', 'true');

		setting('App.indexPage', '');
		setting('App.appTimezone', $_ENV['docker_tz_country'] . '/' . $_ENV['docker_tz_city']);
		setting('App.baseURL', $_ENV['docker_ci_baseurl']);

		CLI::write('Custom setup complete.');
	}
}