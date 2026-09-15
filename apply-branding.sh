#!/usr/bin/env bash
set -euo pipefail

WT="${1:-/Users/mikeserver/immich-v300-branding}"
WEB="$WT/web"

mkdir -p "$WEB/src/lib/constants"
cp /Users/mikeserver/immich-v300-branding/web/src/lib/constants/branding.ts "$WEB/src/lib/constants/"
cp /Users/mikeserver/immich-v300-branding/web/src/lib/components/shared-components/GalleryLogo.svelte "$WEB/src/lib/components/shared-components/"

python3 - <<'PY'
from pathlib import Path

web = Path("/Users/mikeserver/immich-v300-branding/web")

def patch(path: str, replacements: list[tuple[str, str]]):
    p = web / path
    text = p.read_text()
    for old, new in replacements:
        if old not in text:
            raise SystemExit(f"Pattern not found in {path}: {old!r}")
        text = text.replace(old, new)
    p.write_text(text)

manifest = web / "static/manifest.json"
manifest.write_text(
    manifest.read_text()
    .replace('"name": "Immich"', '"name": "Michael\'s Gallery"')
    .replace('"short_name": "Immich"', '"short_name": "Gallery"')
)

layout_ts = web / "src/routes/+layout.ts"
text = layout_ts.read_text()
if "title: 'Immich'" in text:
    text = text.replace("title: 'Immich'", "title: \"Michael's Gallery\"")
    layout_ts.write_text(text)
elif 'title: "Michael\'s Gallery"' not in text and "Michael's Gallery" not in text:
    raise SystemExit("Unexpected +layout.ts title format")

layout_svelte = web / "src/routes/+layout.svelte"
text = layout_svelte.read_text()
if "- Immich</title>" in text:
    text = text.replace("- Immich</title>", "- Michael's Gallery</title>")
    layout_svelte.write_text(text)
elif "Michael's Gallery</title>" not in text:
    raise SystemExit("Unexpected +layout.svelte title format")

files = {
    "src/lib/components/shared-components/navigation-bar/navigation-bar.svelte": [
        ("import { ActionButton, Button, IconButton, Logo } from '@immich/ui';",
         "import { ActionButton, Button, IconButton } from '@immich/ui';\n  import GalleryLogo from '$lib/components/shared-components/GalleryLogo.svelte';"),
        ("<Logo variant={mediaQueryManager.isFullSidebar ? 'inline' : 'icon'} class=\"max-md:h-12\" />",
         "<GalleryLogo variant=\"inline\" class=\"max-md:h-12 max-md:text-sm\" />"),
    ],
    "src/lib/components/share-page/individual-shared-viewer.svelte": [
        ("import { IconButton, Logo, toastManager } from '@immich/ui';",
         "import { IconButton, toastManager } from '@immich/ui';\n  import GalleryLogo from '$lib/components/shared-components/GalleryLogo.svelte';"),
        ("<Logo variant={mediaQueryManager.maxMd ? 'icon' : 'inline'} class=\"min-w-10\" />",
         "<GalleryLogo variant=\"inline\" class=\"min-w-10 max-md:text-sm\" />"),
    ],
    "src/lib/components/album-page/album-viewer.svelte": [
        ("import { ActionButton, IconButton, Logo } from '@immich/ui';",
         "import { ActionButton, IconButton } from '@immich/ui';\n  import GalleryLogo from '$lib/components/shared-components/GalleryLogo.svelte';"),
        ("<Logo variant={mediaQueryManager.maxMd ? 'icon' : 'inline'} class=\"min-w-10\" />",
         "<GalleryLogo variant=\"inline\" class=\"min-w-10 max-md:text-sm\" />"),
    ],
    "src/lib/components/onboarding-page/onboarding-hello.svelte": [
        ("import { Logo } from '@immich/ui';",
         "import GalleryLogo from '$lib/components/shared-components/GalleryLogo.svelte';"),
        ('<Logo variant="icon" size="giant" class="mb-2" />',
         '<GalleryLogo variant="inline" size="giant" class="mb-2" />'),
    ],
    "src/lib/components/shared-components/drag-and-drop-upload-overlay.svelte": [
        ("import { Logo } from '@immich/ui';",
         "import GalleryLogo from '$lib/components/shared-components/GalleryLogo.svelte';"),
        ('<Logo variant="icon" size="giant" class="m-16 animate-bounce" />',
         '<GalleryLogo variant="inline" size="giant" class="m-16 animate-bounce" />'),
    ],
    "src/lib/components/shared-components/side-bar/supporter-badge.svelte": [
        ("import { Logo } from '@immich/ui';",
         "import GalleryLogo from '$lib/components/shared-components/GalleryLogo.svelte';"),
        ("<Logo variant=\"icon\" size={logoSize === 'sm' ? 'tiny' : 'small'} />",
         "<GalleryLogo variant=\"inline\" size={logoSize === 'sm' ? 'tiny' : 'small'} />"),
    ],
    "src/lib/components/shared-components/side-bar/purchase-info.svelte": [
        ("import { Button, Icon, IconButton, Logo, modalManager, SupporterBadge } from '@immich/ui';",
         "import { Button, Icon, IconButton, modalManager, SupporterBadge } from '@immich/ui';\n  import GalleryLogo from '$lib/components/shared-components/GalleryLogo.svelte';"),
        ('<Logo variant="icon" size="tiny" />', '<GalleryLogo variant="inline" size="tiny" />'),
        ('<Logo variant="icon" size="small" />', '<GalleryLogo variant="inline" size="small" />'),
    ],
    "src/lib/components/pages/shared-link-page.svelte": [
        ("import { Button, Logo, PasswordInput } from '@immich/ui';",
         "import { Button, PasswordInput } from '@immich/ui';\n  import GalleryLogo from '$lib/components/shared-components/GalleryLogo.svelte';"),
        ('<Logo variant="inline" />', '<GalleryLogo variant="inline" />'),
        ("' - Immich'", " - Michael's Gallery'"),
    ],
    "src/lib/components/pages/shared-link-error-page.svelte": [
        ("{$t('error')} - Immich", "{$t('error')} - Michael's Gallery"),
    ],
}

for path, replacements in files.items():
    patch(path, replacements)

p = web / "src/lib/components/layouts/ErrorLayout.svelte"
text = p.read_text()
text = text.replace("    Logo,\n", "")
text = text.replace("  } from '@immich/ui';", "  } from '@immich/ui';\n  import GalleryLogo from '$lib/components/shared-components/GalleryLogo.svelte';", 1)
text = text.replace('<Logo variant="inline" />', '<GalleryLogo variant="inline" />')
p.write_text(text)

p = web / "src/lib/components/layouts/auth-page-layout.svelte"
text = p.read_text()
text = text.replace(
    "import { Card, CardBody, CardHeader, Heading, immichLogo, Logo, VStack } from '@immich/ui';",
    "import { Card, CardBody, CardHeader, Heading, VStack } from '@immich/ui';\n  import GalleryLogo from '$lib/components/shared-components/GalleryLogo.svelte';",
)
text = text.replace(
    """      <img
        src={immichLogo}
        class="mx-auto mb-2 h-full max-w-(--breakpoint-md) overflow-hidden antialiased"
        alt="Immich logo"
      />""",
    """      <div
        class="mx-auto mb-2 h-full w-full max-w-(--breakpoint-md) bg-gradient-to-br from-primary/20 via-immich-primary/10 to-transparent"
      ></div>""",
)
text = text.replace('<Logo variant="icon" size="giant" />', '<GalleryLogo variant="inline" size="giant" />')
p.write_text(text)

p = web / "src/lib/modals/server-about-modal.svelte"
text = p.read_text()
text = text.replace(
    "import ServerAboutItem from '$lib/components/ServerAboutItem.svelte';",
    "import ServerAboutItem from '$lib/components/ServerAboutItem.svelte';\n  import { APP_NAME } from '$lib/constants/branding';",
)
text = text.replace('title="Immich"', 'title={APP_NAME}')
p.write_text(text)

person_page = web / "src/routes/(user)/people/[personId]/[[photos=photos]]/[[assetId=id]]/+page.svelte"
person_text = person_page.read_text()
if "handleSelectAllPersonAssets" not in person_text:
    person_text = person_text.replace(
        "  import { getPeopleThumbnailUrl } from '$lib/utils';",
        "  import { getPeopleThumbnailUrl, handlePromiseError } from '$lib/utils';\n  import { selectAllAssets } from '$lib/utils/asset-utils';",
    )
    person_text = person_text.replace(
        "    ContextMenuButton,\n    LoadingSpinner,",
        "    ContextMenuButton,\n    IconButton,\n    LoadingSpinner,",
    )
    person_text = person_text.replace(
        "  import { mdiAccountBoxOutline, mdiAccountMultipleCheckOutline, mdiArrowLeft, mdiDotsVertical } from '@mdi/js';",
        "  import {\n    mdiAccountBoxOutline,\n    mdiAccountMultipleCheckOutline,\n    mdiArrowLeft,\n    mdiDotsVertical,\n    mdiSelectAll,\n  } from '@mdi/js';",
    )
    person_text = person_text.replace(
        """  const Merge: ActionItem = {
    title: $t('merge_people'),
    icon: mdiAccountMultipleCheckOutline,
    onAction: () => {
      viewMode = PersonPageViewMode.MERGE_PEOPLE;
    },
  };
</script>""",
        """  const Merge: ActionItem = {
    title: $t('merge_people'),
    icon: mdiAccountMultipleCheckOutline,
    onAction: () => {
      viewMode = PersonPageViewMode.MERGE_PEOPLE;
    },
  };

  const handleSelectAllPersonAssets = () => {
    handlePromiseError(selectAllAssets(timelineManager, assetMultiSelectManager));
  };
</script>""",
    )
    person_text = person_text.replace(
        """        {#snippet trailing()}
          <ContextMenuButton
            items={[SelectFeaturePhoto, HidePerson, ShowPerson, SetDateOfBirth, Merge, Favorite, Unfavorite]}
            aria-label={$t('open')}
          />
        {/snippet}""",
        """        {#snippet trailing()}
          {#if numberOfAssets > 0}
            <IconButton
              shape="round"
              color="secondary"
              variant="ghost"
              aria-label={$t('select_all')}
              icon={mdiSelectAll}
              onclick={handleSelectAllPersonAssets}
            />
          {/if}
          <ContextMenuButton
            items={[SelectFeaturePhoto, HidePerson, ShowPerson, SetDateOfBirth, Merge, Favorite, Unfavorite]}
            aria-label={$t('open')}
          />
        {/snippet}""",
    )
    person_page.write_text(person_text)

print("Branding applied to v3.0.0 web tree")
PY
