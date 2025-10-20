<?php

namespace App\Http\Controllers;

use App\Models\Auto;
use Illuminate\Http\Request;

class AutosController extends Controller
{
    /**
     * MUESTRA LISTADO DE AUTOS CON SU MARCA
     */
    public function index()
    {
        // CON with('marca') SE INCLUYE LA INFORMACION DE LA MARCA EN EL JSON
        return Auto::with('marca')->orderBy('patentes')->paginate(10);
    }

    /**
     * GUARDA UN NUEVO AUTO
     */
    public function store(Request $request)
    {
        // VALIDAR DATOS RECIBIDOS
        $data = $request->validate([
            'patentes' => ['required','string','size:6','unique:autos,patentes'],
            'modelo'   => ['required','string','max:50'],
            'precio'   => ['required','integer','min:0'],
            'marca_id' => ['required','integer','exists:marcas,id'],
        ]);

        // CREAR Y RETORNAR AUTO NUEVO
        $auto = Auto::create($data);
        return $auto->load('marca');
    }

    /**
     * MUESTRA UN AUTO ESPECIFICO
     */
    public function show(Auto $auto)
    {
        return $auto->load('marca');
    }

    /**
     * ACTUALIZA UN AUTO EXISTENTE
     */
    public function update(Request $request, Auto $auto)
    {
        $data = $request->validate([
            'modelo'   => ['sometimes','required','string','max:50'],
            'precio'   => ['sometimes','required','integer','min:0'],
            'marca_id' => ['sometimes','required','integer','exists:marcas,id'],
        ]);

        $auto->update($data);
        return $auto->load('marca');
    }

    /**
     * ELIMINA UN AUTO
     */
    public function destroy(Auto $auto)
    {
        $auto->delete();
        return response()->json(['mensaje' => 'Auto eliminado correctamente']);
    }
}
