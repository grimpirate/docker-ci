<?php

namespace App\Commands;

use CodeIgniter\CLI\BaseCommand;
use CodeIgniter\CLI\CLI;

class DefaultSetupCommand extends BaseCommand
{
	protected $group = 'Setup';

	protected $name = 'setup:default';

	protected $description = 'Initialize framework';

	protected $usage = 'setup:default';

	public function run(array $params)
	{
		CLI::write('Running default setup...');

		helper('setting');

		/* These settings are not activated if within database
		setting('Session.driver', 'CodeIgniter\Session\Handlers\DatabaseHandler');
		setting('Session.savePath', $_ENV['docker_db_sessions']);
		setting('Session.matchIP', 'true');

		setting('App.indexPage', '');
		setting('App.appTimezone', $_ENV['docker_tz_country'] . '/' . $_ENV['docker_tz_city']);
		setting('App.baseURL', $_ENV['docker_ci_baseurl']);
		*/

		CLI::write('Default setup complete.');
	}
}