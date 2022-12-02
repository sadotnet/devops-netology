

# devops-netology

Будут проигноированы все каталоги с названием .terraform и любые файлы и каталоги в них в какой бы уровне иерархии файловой системы ниже от gitignore они не находились бы
**/.terraform/*

Везде будут проигнорированы файлы которые заканчиваются на .tfstate или содержат ".tfstate." 
*.tfstate
*.tfstate.*

Будут проигнорированы файлы crash.log и все файлы crash.Любые_символы.log
crash.log
crash.*.log

Будут проигнорированы файлы с расширением .tfvars или tfvars.json
*.tfvars
*.tfvars.json

Будут проигнорированы файлы override.tf и override.tf.json
Будут проигноированы файлы заканчивающиеся на _override.tf или _override.tf.json
Будут проигнорированы файлы с расширением .terraformrc и файлы с именем terraform.rc
''
