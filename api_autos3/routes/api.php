<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AutosController;
use App\Http\Controllers\MarcasController;

// ENDPOINTS SIMPLES
Route::get('/autos', [AutosController::class, 'index']);     // GET /api/autos
Route::get('/marcas', [MarcasController::class, 'index']);   // GET /api/marcas

// OPCIONAL: CRUD completo
Route::apiResource('autos', AutosController::class);
Route::apiResource('marcas', MarcasController::class);
