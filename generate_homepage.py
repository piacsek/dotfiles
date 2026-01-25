#!/usr/bin/env python3
"""
Generate a bookmark homepage from Chrome bookmarks.
"""

import json
import os
from pathlib import Path
from datetime import datetime

# Chrome bookmarks location for macOS
BOOKMARKS_PATH = Path.home() / "Library/Application Support/Google/Chrome/Default/Bookmarks"
OUTPUT_PATH = Path(__file__).parent / "homepage.html"


def parse_bookmarks(node, bookmarks_list, folder_path=""):
    """Recursively parse bookmark nodes."""
    if node.get("type") == "url":
        bookmarks_list.append({
            "title": node.get("name", "Untitled"),
            "url": node.get("url", ""),
            "folder": folder_path,
            "date_added": node.get("date_added", 0)
        })
    elif node.get("type") == "folder":
        folder_name = node.get("name", "")
        new_path = f"{folder_path}/{folder_name}" if folder_path else folder_name
        for child in node.get("children", []):
            parse_bookmarks(child, bookmarks_list, new_path)


def generate_html(bookmarks, output_path):
    """Generate HTML homepage from bookmarks."""

    # Group by folder
    folders = {}
    for bookmark in bookmarks:
        folder = bookmark["folder"] or "Other"
        if folder not in folders:
            folders[folder] = []
        folders[folder].append(bookmark)

    html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bookmarks</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background: #1a1a1a;
            color: #e0e0e0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            padding: 40px 20px;
            line-height: 1.6;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
        }

        h1 {
            font-size: 36px;
            margin-bottom: 10px;
            color: #fff;
        }

        .subtitle {
            color: #888;
            margin-bottom: 40px;
            font-size: 14px;
        }

        .search-box {
            margin-bottom: 30px;
        }

        #search {
            width: 100%;
            max-width: 600px;
            padding: 12px 20px;
            font-size: 16px;
            background: #2d2d2d;
            border: 1px solid #404040;
            border-radius: 8px;
            color: #fff;
            outline: none;
        }

        #search:focus {
            border-color: #666;
        }

        .folder {
            margin-bottom: 50px;
        }

        .folder-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 20px;
            color: #fff;
            padding-bottom: 10px;
            border-bottom: 2px solid #333;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 16px;
        }

        .card {
            background: #252525;
            border: 1px solid #333;
            border-radius: 8px;
            padding: 20px;
            text-decoration: none;
            color: #e0e0e0;
            transition: all 0.2s ease;
            display: flex;
            align-items: flex-start;
            gap: 16px;
        }

        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
            border-color: #555;
            background: #2d2d2d;
        }

        .card-icon {
            width: 48px;
            height: 48px;
            border-radius: 8px;
            flex-shrink: 0;
            background: #1a1a1a;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .card-icon img {
            width: 32px;
            height: 32px;
            object-fit: contain;
        }

        .card-content {
            flex: 1;
            min-width: 0;
        }

        .card-title {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 6px;
            color: #fff;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .card-url {
            font-size: 13px;
            color: #888;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .card-folder {
            font-size: 11px;
            color: #666;
            margin-top: 8px;
            padding-top: 8px;
            border-top: 1px solid #333;
        }

        .no-results {
            text-align: center;
            color: #666;
            padding: 40px;
            font-size: 18px;
        }

        @media (max-width: 768px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📚 Bookmarks</h1>
        <div class="subtitle">Generated from Chrome bookmarks • """ + str(len(bookmarks)) + """ total bookmarks</div>

        <div class="search-box">
            <input type="text" id="search" placeholder="Search bookmarks... (or press / to focus)">
        </div>

        <div id="bookmarks-container">
"""

    # Add bookmarks grouped by folder
    for folder_name in sorted(folders.keys()):
        folder_bookmarks = folders[folder_name]
        html += f'            <div class="folder" data-folder="{folder_name}">\n'
        html += f'                <h2 class="folder-title">{folder_name}</h2>\n'
        html += '                <div class="grid">\n'

        for bookmark in sorted(folder_bookmarks, key=lambda x: x['title'].lower()):
            title = bookmark['title'].replace('"', '&quot;')
            url = bookmark['url'].replace('"', '&quot;')

            # Extract domain for display
            try:
                from urllib.parse import urlparse
                domain = urlparse(url).netloc
            except:
                domain = url

            html += f'''                    <a href="{url}" class="card" data-title="{title.lower()}" data-url="{url.lower()}">
                        <div class="card-title">{title}</div>
                        <div class="card-url">{domain}</div>
                    </a>
'''

        html += '                </div>\n'
        html += '            </div>\n'

    html += """        </div>

        <div id="no-results" class="no-results" style="display: none;">
            No bookmarks found matching your search.
        </div>
    </div>

    <script>
        const searchInput = document.getElementById('search');
        const bookmarksContainer = document.getElementById('bookmarks-container');
        const noResults = document.getElementById('no-results');

        // Focus search with "/" key
        document.addEventListener('keydown', (e) => {
            if (e.key === '/' && document.activeElement !== searchInput) {
                e.preventDefault();
                searchInput.focus();
            }
        });

        // Search functionality
        searchInput.addEventListener('input', (e) => {
            const searchTerm = e.target.value.toLowerCase();

            if (!searchTerm) {
                // Show all
                document.querySelectorAll('.folder').forEach(folder => {
                    folder.style.display = 'block';
                });
                document.querySelectorAll('.card').forEach(card => {
                    card.style.display = 'block';
                });
                noResults.style.display = 'none';
                bookmarksContainer.style.display = 'block';
                return;
            }

            let hasResults = false;

            document.querySelectorAll('.folder').forEach(folder => {
                let visibleCards = 0;

                folder.querySelectorAll('.card').forEach(card => {
                    const title = card.dataset.title;
                    const url = card.dataset.url;

                    if (title.includes(searchTerm) || url.includes(searchTerm)) {
                        card.style.display = 'block';
                        visibleCards++;
                        hasResults = true;
                    } else {
                        card.style.display = 'none';
                    }
                });

                folder.style.display = visibleCards > 0 ? 'block' : 'none';
            });

            if (!hasResults) {
                bookmarksContainer.style.display = 'none';
                noResults.style.display = 'block';
            } else {
                bookmarksContainer.style.display = 'block';
                noResults.style.display = 'none';
            }
        });
    </script>
</body>
</html>
"""

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(html)


def main():
    """Main function."""
    if not BOOKMARKS_PATH.exists():
        print(f"❌ Chrome bookmarks not found at: {BOOKMARKS_PATH}")
        print("\nPlease update BOOKMARKS_PATH in the script if your Chrome profile is in a different location.")
        return

    print(f"📖 Reading bookmarks from: {BOOKMARKS_PATH}")

    try:
        with open(BOOKMARKS_PATH, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"❌ Error reading bookmarks: {e}")
        return

    bookmarks = []

    # Parse bookmark bar and other bookmarks
    if "roots" in data:
        for root_name in ["bookmark_bar", "other", "synced"]:
            if root_name in data["roots"]:
                parse_bookmarks(data["roots"][root_name], bookmarks, "")

    print(f"✅ Found {len(bookmarks)} bookmarks")

    # Generate HTML
    generate_html(bookmarks, OUTPUT_PATH)
    print(f"✅ Generated homepage at: {OUTPUT_PATH}")
    print(f"\nTo use as Chrome homepage:")
    print(f"  1. Open chrome://settings/")
    print(f"  2. Under 'On startup', select 'Open a specific page'")
    print(f"  3. Add: file://{OUTPUT_PATH.resolve()}")
    print(f"\nWith Vimium, press 'f' to show link hints and navigate with keyboard!")


if __name__ == "__main__":
    main()
