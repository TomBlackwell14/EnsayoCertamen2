<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;


class Marca extends Model
{
    use HasFactory, SoftDeletes;

    // TABLA ASOCIADA AL MODELO
    protected $table = 'marcas';

    // RELACION UNO A MUCHOS: UNA MARCA TIENE MUCHOS AUTOS
    public function autos()
    {
        return $this->hasMany(Auto::class);
    }
}
