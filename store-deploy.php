<?php
// Eenmalig deploy-script — verwijdert zichzelf na uitvoering
$secret = 'zoluma_store_deploy_2026';
if (($_GET['s'] ?? '') !== $secret) { http_response_code(403); exit('Verboden'); }

$base = 'https://raw.githubusercontent.com/nieuwetijdsopleidingen/zolumaos/main/store/frontend/dist/';
$root = __DIR__;

$files = [
    'index.html'                    => $base . 'index.html',
    'packages.json'                 => $base . 'packages.json',
    'assets/index-DGt1Xzyh.js'     => $base . 'assets/index-DGt1Xzyh.js',
    'assets/index-c5ZZINld.css'     => $base . 'assets/index-c5ZZINld.css',
];

$ok = []; $err = [];
foreach ($files as $local => $url) {
    $dir = dirname("$root/$local");
    if (!is_dir($dir)) mkdir($dir, 0755, true);
    $data = file_get_contents($url);
    if ($data === false) { $err[] = $local; continue; }
    file_put_contents("$root/$local", $data);
    $ok[] = $local;
}

echo "OK: " . implode(', ', $ok) . "\n";
if ($err) echo "FOUT: " . implode(', ', $err) . "\n";

unlink(__FILE__);
echo "Script verwijderd.\n";
