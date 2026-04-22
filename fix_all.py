"import os

# Fix files that have leading/trailing quotes
files_to_fix = [
    'lib/services/cache_service.dart',
    'lib/services/data_service.dart',
    'lib/services/ai_service.dart',
    'lib/providers/module_provider.dart',
    'lib/pages/home_page.dart',
    'lib/config/constants.dart',
    'lib/config/routes.dart',
    'lib/config/theme.dart',
    'lib/models/module_config.dart',
    'lib/models/daily_content.dart',
    'lib/providers/daily_content_provider.dart',
    'lib/widgets/daily_card.dart',
    'lib/widgets/module_grid_item.dart',
    'lib/pages/module_detail_page.dart',
    'lib/pages/poster_page.dart',
    'lib/pages/mine_page.dart',
]

for fp in files_to_fix:
    if os.path.exists(fp):
        with open(fp, 'r', encoding='utf-8') as f:
            content = f.read()
        # Strip leading/trailing double quotes
        if content.startswith('"') and content.endswith('"'):
            content = content[1:-1]
            # Replace escaped newlines with real ones
            content = content.replace('\\n', '\n')
            with open(fp, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Stripped quotes: {fp}')
        else:
            print(f'No quotes to strip: {fp}')
    else:
        print(f'Not found: {fp}')

print('Done!')"