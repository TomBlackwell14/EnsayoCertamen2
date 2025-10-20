<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],

    // Para desarrollo local, esto funciona bien.
    // OJO: el comodín '*' es válido si supports_credentials = false.
    'allowed_origins' => ['*'],
    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,

    // MUY IMPORTANTE: debe ser true/false (booleano), no 'f', ni texto.
    'supports_credentials' => false,
];
