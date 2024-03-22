if [ ! -d "./lambdas/authorizer" ]; then
  git clone https://github.com/jeffersoncleyson/fiap-hackthon-2024-lambda-authorizer.git -b main ./lambdas/authorizer
else
  git -C ./lambdas/authorizer/ pull origin main
fi

if [ ! -d "./lambdas/login" ]; then
  git clone https://github.com/jeffersoncleyson/fiap-hackthon-2024-lambda-login.git -b main ./lambdas/login
else
  git -C ./lambdas/login/ pull origin main
fi

if [ ! -d "./lambdas/ponto" ]; then
  git clone https://github.com/jeffersoncleyson/fiap-hackthon-2024-lambda-ponto.git -b main ./lambdas/ponto
else
  git -C ./lambdas/ponto/ pull origin main
fi

if [ ! -d "./lambdas/usuario" ]; then
  git clone https://github.com/jeffersoncleyson/fiap-hackthon-2024-lambda-usuario.git -b main ./lambdas/usuario
else
  git -C ./lambdas/usuario/ pull origin main
fi

if [ ! -d "./lambdas/relatorio" ]; then
  git clone https://github.com/jeffersoncleyson/fiap-hackthon-2024-lambda-relatorio.git -b main ./lambdas/relatorio
else
  git -C ./lambdas/relatorio/ pull origin main
fi