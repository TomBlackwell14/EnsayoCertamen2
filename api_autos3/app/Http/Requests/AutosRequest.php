<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AutosRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return false;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            //17-10
            'patente' => 'require|size:6|unique:autos,patente',
            'modelo' => 'required|min:3',
            'precio' => 'required|integer|gte:1',
        ];
    }

    public function messages(){
        return [
            'patente.required' => 'Indique patente del auto',
            'patente.size' => 'La patente debe tener 6 caracteres',
            'patente.unique' => 'La patente ya existe',
            'modelo.required' => 'Indique modelo del auto',
            'modelo.min' => 'El modelo debe tener 3 letras como mínimo',
            'precio.required' => 'Indique precio del auto',
            'precio.integer' => 'El precio no puede llevar decimales',
            'precio.gte' => 'El precio debe ser como mínimo 1',

        ];
    }
}
