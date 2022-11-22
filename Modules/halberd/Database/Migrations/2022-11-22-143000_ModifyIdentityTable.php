<?php

declare(strict_types=1);

namespace Halberd\Database\Migrations;

use CodeIgniter\Database\Migration;

class ModifyIdentityTable extends Migration
{
    public const COLUMN_NAME = 'qrcode2fa';

    public function up(): void
    {
        /*
         * Auth Identities Table
         * Used for storage of passwords, access tokens, social login identities, etc.
         */
        $this->forge->addColumn('auth_identities', [
            self::COLUMN_NAME => ['type' => 'varchar', 'constraint' => 255, 'null' => true],
        ]);
    }

    // --------------------------------------------------------------------

    public function down(): void
    {
        $this->db->disableForeignKeyChecks();

        $this->forge->dropColumn('auth_identities', self::COLUMN_NAME);

        $this->db->enableForeignKeyChecks();
    }
}
