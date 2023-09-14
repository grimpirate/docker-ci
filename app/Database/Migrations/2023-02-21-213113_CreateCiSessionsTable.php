<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;
use CodeIgniter\Database\RawSql;

class CreateCiSessionsTable extends Migration
{
	protected $DBGroup = 'default';

	public function up()
	{
		$this->forge->addField([
			'id' => [
				'type' => 'VARCHAR',
				'constraint' => 128,
				'null' => false],
			'ip_address' => [
				'type' => 'VARCHAR',
				'constraint' => 45,
				'null' => false],
			'timestamp' => [
				'type' => 'TIMESTAMP',
				'default' => new RawSql('CURRENT_TIMESTAMP'),
				'null' => false],
			'data' => [
				'type' => 'BLOB',
				'null' => false]
		]);
		$this->forge->addKey(['id', 'ip_address'], true);
		$this->forge->addKey('timestamp');
		$this->forge->createTable($_ENV['docker.db_sessions'], true);
	}

	public function down()
	{
		$this->forge->dropTable($_ENV['docker.db_sessions'], true);
	}
}