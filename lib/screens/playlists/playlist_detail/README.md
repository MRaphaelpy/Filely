# Playlist Detail Screen - Estrutura Modular

Este diretório contém os componentes modulares da tela de detalhes da playlist, divididos para facilitar a manutenção e reutilização.

## Estrutura de Arquivos

### Widgets (`widgets/`)

- **`playlist_detail_sliver_app_bar.dart`** - AppBar expansível com informações da playlist
- **`playlist_detail_header.dart`** - Cabeçalho com nome, estatísticas e descrição da playlist
- **`playlist_detail_control_buttons.dart`** - Botões de reproduzir e reprodução aleatória
- **`playlist_detail_section_divider.dart`** - Divisor de seção reutilizável
- **`playlist_detail_song_tile.dart`** - Tile individual de música na playlist
- **`playlist_detail_songs_list.dart`** - Lista de músicas com reordenação
- **`playlist_detail_empty_state.dart`** - Estado vazio quando a playlist não tem músicas
- **`playlist_detail_options_sheet.dart`** - Bottom sheet com opções da playlist
- **`playlist_detail_song_options_sheet.dart`** - Bottom sheet com opções de música

### Diálogos (`dialogs/`)

- **`playlist_detail_edit_dialog.dart`** - Diálogo para editar nome e descrição da playlist
- **`playlist_detail_delete_dialog.dart`** - Diálogo de confirmação para excluir playlist

### Arquivo Principal

- **`../playlist_detail_screen.dart`** - Tela principal que orquestra todos os componentes

### Arquivo de Exportação

- **`playlist_detail_exports.dart`** - Arquivo de conveniência para importar todos os componentes

## Benefícios da Modularização

1. **Manutenibilidade**: Cada componente tem responsabilidade única e é fácil de manter
2. **Reutilização**: Widgets podem ser reutilizados em outras partes do app
3. **Testabilidade**: Componentes pequenos são mais fáceis de testar
4. **Legibilidade**: Código mais limpo e organizado
5. **Colaboração**: Diferentes desenvolvedores podem trabalhar em componentes diferentes

## Como Usar

Para usar todos os componentes:

```dart
import 'playlist_detail/playlist_detail_exports.dart';
```

Ou importar componentes individuais:

```dart
import 'playlist_detail/widgets/playlist_detail_header.dart';
import 'playlist_detail/dialogs/playlist_detail_edit_dialog.dart';
```

## Padrões Seguidos

- Widgets stateless quando possível
- Callbacks para comunicação entre componentes
- Separação clara entre widgets e diálogos
- Nomenclatura consistente e descritiva
- Documentação e comentários quando necessário
