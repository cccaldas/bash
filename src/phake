#!/usr/bin/env php
<?php
$action = $argv[1];
$phake_file = 'PhakeFile';

if(!file_exists($phake_file)){
    echo "PhakeFile not found! \n";
    exit();
}

require_once($phake_file);

if(function_exists($action))
    eval("$action();");
else
    echo "task not found: '$action' \n";

?>