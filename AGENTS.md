# Contexto do projeto

Mira é um aplicativo nativo para macOS, escrito em Swift com AppKit. Ele fica na barra de menus e permite capturar uma área ou a tela principal, desenhar setas vermelhas, desfazer a última seta e copiar ou salvar a imagem em PNG. A interface e a documentação são em português.

## Organização

- `Sources/main.swift`: inicialização do aplicativo.
- `Sources/App/AppDelegate.swift`: barra de menus, captura com `/usr/sbin/screencapture` e ciclo de vida das janelas.
- `Sources/Editor/ArrowView.swift`: interação com as setas, desenho e exportação de PNG.
- `Sources/Editor/EditorWindowController.swift`: janela do editor, ações e atalho de teclado.
- `Resources/Info.plist`: metadados do aplicativo.
- `Assets/`: arte e ícone do aplicativo; o build usa `AppIcon.icns`.
- `build.sh`: compila o aplicativo e cria o instalador.
- `scripts/criar-instalador.sh`: atalho de compatibilidade para `build.sh`.

## Compilação e verificação

Execute `./build.sh` no macOS com as ferramentas de linha de comando do Xcode. O comando gera `Mira.app` e `dist/Mira-1.0.pkg`; o pacote instala o aplicativo em `/Applications`. O build usa a arquitetura da máquina, tem como alvo o macOS 11 ou posterior e aplica assinatura local ao aplicativo. O pacote não é assinado e nenhum dos dois é notarizado.

Não há testes automatizados configurados. Depois de mudanças em código ou scripts, execute o build. Quando a alteração afetar a interface ou a captura, teste também no macOS: captura de área e cancelamento com Esc, captura da tela principal, desenho e desfazer, redimensionamento, cópia com botão e ⌘C, e salvamento em PNG, conforme o escopo. Informe quando não for possível fazer a verificação visual.

## Cuidados de implementação

- Mantenha as coordenadas das setas relativas à imagem, para preservar sua posição ao redimensionar o editor e na exportação.
- Copiar com sucesso fecha a janela do editor; salvar mantém a janela aberta.
- A captura de área cancelada pode não gerar arquivo; evite tratar o cancelamento como erro sem confirmar o comportamento do `screencapture`.
- Preserve o comportamento de aplicativo de barra de menus e a compatibilidade com macOS 11 ao introduzir APIs.
- Mantenha `README.md` e as instruções de build coerentes com mudanças de comportamento ou estrutura.
- `Mira.app/`, `dist/` e `.build/` são artefatos gerados e estão no `.gitignore`.
