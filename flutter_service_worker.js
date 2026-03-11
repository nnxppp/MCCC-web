'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "b53837996a32025a72a27cb064eebf1d",
".git/config": "0b31aa23dba0762334fb931354aff736",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "5ab7a4355e4c959b0c5c008f202f51ec",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "79c1a1a97622aea8622dfa5a2d0458ce",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "908e387f78461931071992ea1ae1a1ca",
".git/logs/refs/heads/gh-pages": "582efaa5f1ff6d8d89c8692d4695c691",
".git/logs/refs/remotes/origin/gh-pages": "a6c30733ae5de414ce9304896c90aac9",
".git/objects/02/1d4f3579879a4ac147edbbd8ac2d91e2bc7323": "9e9721befbee4797263ad5370cd904ff",
".git/objects/0b/5795ff5b9e0f87adce44e104c89bdda2e83b81": "fb9d1956f7c38fba730de40dfc379ed6",
".git/objects/0c/f4248a3cde42abb6fe088539e1206beb0b4c0e": "d9df89454c1bf606174d463904089f56",
".git/objects/10/a83d4222c194cfe4c9447b0a3bacd6b3933a46": "51f792e7a125c1b818b7c50ddbf2db98",
".git/objects/10/b08c8a41d23d4abf8348c27a8cfec8a9e37184": "0cbc83317a370be8d801189288a9a16f",
".git/objects/17/37f2ef3ca017a2669c77d7b0ee976a7425a34c": "c32876ce3516f4ea4e13ffc595d6c88f",
".git/objects/1c/8ddcd71517b034232c0d17a918e320eba0df94": "cfc0be3c5e7cfc58d00c198af34c6e3d",
".git/objects/20/3a3ff5cc524ede7e585dff54454bd63a1b0f36": "4b23a88a964550066839c18c1b5c461e",
".git/objects/21/acb7307303ac75c3c18bab6cc9d86b0a00bf9c": "5d1d7bae3e4f1f3f557bbc383c4963f5",
".git/objects/22/4272afa1740b98c20985374a37863b7af1b6bf": "801644a8e506d5e1433e7c02cf60f40d",
".git/objects/28/421228f3507faed0c470adb58b4d08fe3ab332": "7bf5b00ca189a0f2bee29a80bad23368",
".git/objects/29/ca4b4946925936fdecf3febfd2d61462fdec9e": "c488997e6f30514ccf2d29e5b3b94749",
".git/objects/29/f22f56f0c9903bf90b2a78ef505b36d89a9725": "e85914d97d264694217ae7558d414e81",
".git/objects/2c/bc403c0a69ac29ed41a6ad242b0be614e151ad": "3bff01f2fa4d9f6cab21cc13c73def59",
".git/objects/37/0671d82f292e6a573dbfa20d26f8d14c71952d": "c8303986531f2b95b0ab3096b7242b72",
".git/objects/4b/4d97aabd2df91317b34f1cf1eea15634fdcf6c": "70d8d60c6953e41d4f9afeec208d3542",
".git/objects/4b/61f1db898b695713c583ec0585f64361d286b2": "8b169895e5f16b5ff860d4c6e74f807b",
".git/objects/4d/bf9da7bcce5387354fe394985b98ebae39df43": "534c022f4a0845274cbd61ff6c9c9c33",
".git/objects/4f/fbe6ec4693664cb4ff395edf3d949bd4607391": "2beb9ca6c799e0ff64e0ad79f9e55e69",
".git/objects/65/f498626c3be9511f48f39068088f478f885c63": "4d5a8cd197257786712614fadf2af95e",
".git/objects/66/9739c66a3c5aa4e6bc2f864f415eb78f2c079b": "b28afa2991d90fe156e4e5848e26563b",
".git/objects/6f/c0c7e13c2fd9e007f9b38f7d8cbeb3f9da06b2": "61a0737b505d6827114599e826d69683",
".git/objects/73/759490f46cb5607c534ca3c4cda58b75842f1b": "dad8d2e081ffca105951a59eab30330f",
".git/objects/74/f9e57ee25f9784b8e024d6b8aa6735da12072d": "27e542e83440b8e1dac3e4d22800cd57",
".git/objects/7a/6c1911dddaea52e2dbffc15e45e428ec9a9915": "f1dee6885dc6f71f357a8e825bda0286",
".git/objects/7f/72a6e14430730b12741208127d35d427975fa6": "8e2a7b38a96c599ac2aeb37fa5dde010",
".git/objects/7f/f7b761475683e36ae68b096b0027424fc5149d": "03adffd554879b1555bbd849a48c62a0",
".git/objects/80/279f76498c066824f76db66a9b1fea28af5cef": "c8917bd9de7cda3f96a20c0de9c67b64",
".git/objects/88/385a43200c614eed72186ca5288fb9a56c4ecb": "d503a276f805a72998de40dc84ae642e",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/89/8afc684dd078e61f4ea4205dc15b0f246b882f": "c477a3996cf8c31d7eff8a266e741451",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/95/6e9e3f87566baec212df12568be32aa2ef1691": "c43171c54e2f9c472af205ec11fedea8",
".git/objects/96/48aaddf58dd71577f565ff8f692df664496332": "0aee41990ade71d537850b869dc89033",
".git/objects/98/0d49437042d93ffa850a60d02cef584a35a85c": "8e18e4c1b6c83800103ff097cc222444",
".git/objects/9b/3ef5f169177a64f91eafe11e52b58c60db3df2": "91d370e4f73d42e0a622f3e44af9e7b1",
".git/objects/9e/3b4630b3b8461ff43c272714e00bb47942263e": "accf36d08c0545fa02199021e5902d52",
".git/objects/a1/685b6eade2c6249b42b65a99c81d045a446ac0": "9003ec45cab3eaed678875e0bdbb083b",
".git/objects/b0/4398bf949e4d46a0cd52011e85fcc6510cb411": "32dd58c360cc756b52ae2a8c93a882cd",
".git/objects/b2/26871a498e3516c216c87d2d01b0696dd53980": "f7f4aaa8d33cbea094aab9acc1c5516a",
".git/objects/b5/0912978f75fcf5c773a5a07ce515591a8de7a0": "250ed521aa73f031d72aa4c520fd4a63",
".git/objects/b6/b8806f5f9d33389d53c2868e6ea1aca7445229": "b14016efdbcda10804235f3a45562bbf",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b7/ffe4f51be7fa985e6353e5500d1f15bb0da273": "5d4505741fd9f367b22d110a318dc617",
".git/objects/b9/2a0d854da9a8f73216c4a0ef07a0f0a44e4373": "f62d1eb7f51165e2a6d2ef1921f976f3",
".git/objects/c4/016f7d68c0d70816a0c784867168ffa8f419e1": "fdf8b8a8484741e7a3a558ed9d22f21d",
".git/objects/ca/3bba02c77c467ef18cffe2d4c857e003ad6d5d": "316e3d817e75cf7b1fd9b0226c088a43",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d6/9c56691fbdb0b7efa65097c7cc1edac12a6d3e": "868ce37a3a78b0606713733248a2f579",
".git/objects/db/cf14424117bd15f0842936c7ff95a8fe946cd8": "91218e6be08bfa457f34a2756f63e959",
".git/objects/e3/e9ee754c75ae07cc3d19f9b8c1e656cc4946a1": "14066365125dcce5aec8eb1454f0d127",
".git/objects/e6/be641168067a1220c82296635202ecf13857a4": "9acd29da57872a7c63605add0c80ac5d",
".git/objects/eb/9b4d76e525556d5d89141648c724331630325d": "37c0954235cbe27c4d93e74fe9a578ef",
".git/objects/ed/b55d4deb8363b6afa65df71d1f9fd8c7787f22": "886ebb77561ff26a755e09883903891d",
".git/objects/f1/12dc04a95971cd1a556ac7fff90a7eee07a4a6": "721d7ed29a1a87d6907d55f6be093aff",
".git/objects/f2/04823a42f2d890f945f70d88b8e2d921c6ae26": "6b47f314ffc35cf6a1ced3208ecc857d",
".git/objects/fe/3b987e61ed346808d9aa023ce3073530ad7426": "dc7db10bf25046b27091222383ede515",
".git/refs/heads/gh-pages": "439c013f1152aa0b166dfec019a16ef5",
".git/refs/remotes/origin/gh-pages": "439c013f1152aa0b166dfec019a16ef5",
"assets/AssetManifest.bin": "95699a5df2b83d3a6c6c74009c6a4a0e",
"assets/AssetManifest.bin.json": "7b8cce5d745741dc789104d82e4770df",
"assets/AssetManifest.json": "563dd22716b90631d06f118b6b12fa2f",
"assets/assets/bottom_login.png": "f8cda370aba2f9f67e82e0a2f81bd6ab",
"assets/assets/bottom_menu.png": "dd0bd7651a92f5d32c3867506543f41b",
"assets/assets/fonts/NotoSansThai-Regular.ttf": "07d8702d3a1417d3b5407d2ecdc94e22",
"assets/assets/fonts/NotoSansThai-Regular.zip": "9ab34534d26c6b05766f347a7c5f6b3f",
"assets/assets/leaf.png": "b6be67b6044b841d4d49c5a9a2905f84",
"assets/assets/mccc.png": "b76ed035ab7df98af8b218b21affc452",
"assets/assets/top_login.png": "bce30974425f75cfada17e2287becc77",
"assets/assets/top_menu.png": "5959999aad86f69b278512da84f62286",
"assets/FontManifest.json": "dc7ff4572b581dd2d96e50203a0f5202",
"assets/fonts/MaterialIcons-Regular.otf": "34962a22271344029351b4a247ad4969",
"assets/NOTICES": "3006a153ccda9a4c3be2d723e1131e3a",
"assets/packages/esc_pos_utils_plus/resources/capabilities.json": "cfcc98d389d1ee4358f773efe8a9cdac",
"assets/packages/win_ble/assets/BLEServer.exe": "28aa0e2566083c860f029ff4bc32c4ce",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "f0d24c67c13576170bb6dba5c59c9025",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "d77585c376b766cbe88d09ad065d5379",
"/": "d77585c376b766cbe88d09ad065d5379",
"main.dart.js": "033221c94280b2b409d74f48e7ae9ced",
"manifest.json": "4399b6b3a9481250efaabdc7992d4813",
"version.json": "ff966ab969ba381b900e61629bfb9789"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
