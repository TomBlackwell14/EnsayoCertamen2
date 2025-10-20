<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Auto extends Model
{
    use HasFactory;

    protected $table = 'autos';

    public $timestamps = false;

    protected $primaryKey = 'patentes';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ['patentes','modelo','precio','marca_id'];

    public function marca()
    {
        return $this->belongsTo(Marca::class, 'marca_id');
    }
}
