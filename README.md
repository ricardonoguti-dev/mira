# Mira

O Mira é um aplicativo nativo para macOS que captura a tela e permite adicionar setas vermelhas antes de copiar ou salvar a imagem. Ele fica na barra de menus.

## Requisitos

- macOS 11 ou posterior.
- Ferramentas de linha de comando do Xcode para compilar.
- Permissão de gravação de tela, quando solicitada pelo macOS.

## Compilar e criar o instalador

No Terminal, dentro da pasta do projeto, execute:

```sh
./build.sh
```

O comando cria `Mira.app` na pasta do projeto e o instalador `dist/Mira-1.0.pkg`. O aplicativo é compilado para a arquitetura do Mac usado no build.

Para instalar, abra o arquivo `.pkg` e siga as instruções. O Mira será instalado na pasta **Aplicativos**. O aplicativo recebe uma assinatura local; o pacote não é assinado e nenhum dos dois é notarizado. A distribuição para outros Macs requer assinatura e notarização adequadas.

## Como usar

1. Abra o Mira e clique no ícone de captura na barra de menus.
2. Escolha **Capturar área…** ou **Capturar tela inteira**. A captura de tela inteira usa a tela principal. Pressione `Esc` para cancelar uma seleção de área.
3. No editor, arraste sobre a imagem para desenhar setas. Use **Desfazer** para remover a última seta.
4. Clique em **Copiar** ou pressione **⌘C** para copiar a imagem e fechar o editor. Para manter uma cópia em arquivo, use **Salvar PNG…**.

O macOS pode solicitar permissão em **Ajustes do Sistema > Privacidade e Segurança > Gravação de Tela**. Se o sistema bloquear a abertura, clique com o botão direito no aplicativo e escolha **Abrir**. Para iniciar o Mira com o Mac, adicione-o em **Ajustes do Sistema > Geral > Itens de Início**.

## Estrutura do projeto

```text
Mira/
├── AGENTS.md                  # Contexto e orientações para trabalho no projeto
├── Assets/                    # Ícone e arte original
├── Resources/Info.plist       # Metadados do aplicativo
├── Sources/
│   ├── main.swift             # Ponto de entrada
│   ├── App/                   # Menu e captura de tela
│   └── Editor/                # Janela, setas e exportação
├── scripts/
│   └── criar-instalador.sh    # Atalho de compatibilidade para o build
└── build.sh                   # Cria o aplicativo e o instalador
```

`Mira.app`, `dist/` e `.build/` são artefatos gerados e estão listados no `.gitignore`. Não há testes automatizados configurados; alterações na interface e na captura devem ser verificadas também em execução no macOS.
