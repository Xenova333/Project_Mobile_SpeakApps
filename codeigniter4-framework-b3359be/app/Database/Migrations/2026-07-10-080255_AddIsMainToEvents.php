<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class AddIsMainToEvents extends Migration
{
    public function up()
    {
        $fields = [
            'is_main' => [
                'type'       => 'TINYINT',
                'constraint' => 1,
                'default'    => 0,
            ],
        ];
        $this->forge->addColumn('events', $fields);
    }

    public function down()
    {
        $this->forge->dropColumn('events', 'is_main');
    }
}
