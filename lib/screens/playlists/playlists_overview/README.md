# Playlists Overview Screen - Estrutura Modular

Este diretório contém os componentes modulares da tela de visão geral das playlists, divididos para facilitar a manutenção e reutilização.

## Estrutura de Arquivos

### Widgets (`widgets/`)

- **`playlists_empty_state.dart`** - Estado vazio quando não há playlists criadas
- **`playlists_grid.dart`** - Grade principal de playlists usando SliverGrid
- **`playlists_grid_item.dart`** - Card individual de playlist na grade
- **`playlists_options_sheet.dart`** - Bottom sheet com opções da playlist (renomear, excluir, reproduzir)

### Diálogos (`dialogs/`)

- **`playlists_rename_dialog.dart`** - Diálogo para renomear playlist
- **`playlists_delete_dialog.dart`** - Diálogo de confirmação para excluir playlist

### Arquivo Principal

- **`../playlists_screen.dart`** - Tela principal que orquestra todos os componentes

### Arquivo de Exportação

- **`playlists_overview_exports.dart`** - Arquivo de conveniência para importar todos os componentes

## Componentes Extraídos

1. **Empty State** - Estado quando nenhuma playlist foi criada
2. **Grid Layout** - Layout em grade responsivo para as playlists
3. **Grid Item** - Card individual com cover art, botão de play e opções
4. **Options Sheet** - Bottom sheet com ações da playlist
5. **Rename Dialog** - Diálogo para editar nome da playlist
6. **Delete Dialog** - Confirmação de exclusão

## Benefícios da Modularização

1. **Manutenibilidade**: Cada componente tem responsabilidade única
2. **Reutilização**: Widgets podem ser usados em outras telas
3. **Testabilidade**: Componentes pequenos são mais fáceis de testar
4. **Legibilidade**: Código mais limpo e organizado
5. **Colaboração**: Diferentes desenvolvedores podem trabalhar em componentes diferentes

## Redução de Código

**Antes:** 606 linhas em um único arquivo
**Depois:** ~150 linhas no arquivo principal + componentes modulares

## Como Usar

Para usar todos os componentes:

```dart
import 'playlists_overview/playlists_overview_exports.dart';
```

Ou importar componentes individuais:

```dart
import 'playlists_overview/widgets/playlists_grid.dart';
import 'playlists_overview/dialogs/playlists_rename_dialog.dart';
```

## Padrões Seguidos

- Widgets stateless quando possível
- Callbacks para comunicação entre componentes
- Separação clara entre widgets e diálogos
- Nomenclatura consistente e descritiva
- Responsividade mantida no layout em grade
- Material Design seguindo as diretrizes do Flutter
