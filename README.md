# Mira

Aplicativo para macOS que captura a tela e permite adicionar setas vermelhas antes de copiar ou salvar a imagem. O Mira funciona a partir da barra de menus.

## Requisitos

- macOS 11 ou posterior.
- Ferramentas de linha de comando do Xcode para compilar o projeto.
- Permissão de gravação de tela, quando solicitada pelo macOS.

## Compilação

No Terminal, dentro da pasta do projeto, execute:

```sh
./compilar.sh
```

O script cria `Mira.app` na pasta do projeto e aplica uma assinatura local. Para distribuir o aplicativo a outras pessoas, considere os requisitos de assinatura e notarização da Apple.

## Instalador

Para gerar o instalador `dist/Mira-1.0.pkg`, execute:

```sh
./scripts/criar-instalador.sh
```

Abra o arquivo `.pkg` e siga as instruções para instalar o Mira na pasta **Aplicativos**. O pacote não é assinado, e o aplicativo usa uma assinatura local; nenhum dos dois é notarizado; a distribuição para outros Macs requer assinatura e notarização adequadas.

## Como usar

1. Abra `Mira.app` e clique no ícone do Mira na barra de menus.
2. Escolha **Capturar área…** ou **Capturar tela inteira**. A captura de tela inteira usa a tela principal.
3. Na janela de edição, arraste sobre a imagem para desenhar setas. Use **Desfazer seta** para remover a última.
4. Clique em **Copiar** ou pressione **⌘C** para copiar a imagem, ou clique em **Salvar PNG…**.

Pressione `Esc` para cancelar uma seleção de área. Para iniciar o Mira com o Mac, adicione-o em **Ajustes do Sistema > Geral > Itens de Início**.

Se a captura não funcionar, confira a permissão em **Ajustes do Sistema > Privacidade e Segurança > Gravação de Tela**. Se o macOS bloquear a abertura, clique com o botão direito no aplicativo e escolha **Abrir**.

## Estrutura

```text
Mira/
├── Assets/                    # Ícone e arte original
├── Resources/Info.plist       # Metadados do aplicativo
├── scripts/                   # Geração do instalador
├── Sources/
│   ├── main.swift             # Ponto de entrada
│   ├── App/                   # Menu e captura de tela
│   └── Editor/                # Janela, setas e exportação
└── compilar.sh                # Compilação e montagem do aplicativo
```

O aplicativo e o instalador gerados são artefatos de compilação e estão listados no `.gitignore`.
