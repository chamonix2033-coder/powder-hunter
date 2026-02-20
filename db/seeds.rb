SkiResort.destroy_all

SkiResort.create!([
  { name_en: 'Niseko United (Hokkaido)', name_ja: 'ニセコユナイテッド', latitude: 42.8688, longitude: 140.6974, elevation_base: 300.0, elevation_top: 1308.0 },
  { name_en: 'Hakuba Valley (Nagano)', name_ja: '白馬バレー', latitude: 36.7001, longitude: 137.8398, elevation_base: 750.0, elevation_top: 1831.0 },
  { name_en: 'Nozawa Onsen (Nagano)', name_ja: '野沢温泉スキー場', latitude: 36.9208, longitude: 138.4501, elevation_base: 565.0, elevation_top: 1650.0 },
  { name_en: 'Myoko Suginohara (Niigata)', name_ja: '妙高杉ノ原', latitude: 36.8833, longitude: 138.1667, elevation_base: 731.0, elevation_top: 1855.0 },
  { name_en: 'Hakkoda Ski Area (Aomori)', name_ja: '八甲田スキー場', latitude: 40.655, longitude: 140.849, elevation_base: 660.0, elevation_top: 1324.0 },
  { name_en: 'Kagura Ski Resort (Niigata)', name_ja: 'かぐらスキー場', latitude: 36.882, longitude: 138.756, elevation_base: 620.0, elevation_top: 1845.0 },
  { name_en: 'Tanigawadake Tenjindaira (Gunma)', name_ja: '谷川岳天神平スキー場', latitude: 36.835, longitude: 138.964, elevation_base: 1319.0, elevation_top: 1500.0 },
  { name_en: 'Asahidake Ropeway (Hokkaido)', name_ja: '大雪山旭岳', latitude: 43.664, longitude: 142.809, elevation_base: 1100.0, elevation_top: 1600.0 },
  { name_en: 'Kurodake Ropeway (Hokkaido)', name_ja: '大雪山黒岳', latitude: 43.714, longitude: 142.919, elevation_base: 670.0, elevation_top: 1300.0 },
  { name_en: 'Furano Ski Resort (Hokkaido)', name_ja: '富良野スキー場', latitude: 43.326, longitude: 142.348, elevation_base: 235.0, elevation_top: 1209.0 },
  { name_en: 'Kiroro Snow World (Hokkaido)', name_ja: 'キロロスノーワールド', latitude: 43.072, longitude: 140.981, elevation_base: 570.0, elevation_top: 1180.0 },
  { name_en: 'Lotte Arai Resort (Niigata)', name_ja: 'ロッテアライリゾート', latitude: 36.983, longitude: 138.187, elevation_base: 329.0, elevation_top: 1429.0 },
  { name_en: 'Shizukuishi Ski Resort (Iwate)', name_ja: '雫石スキー場', latitude: 39.761, longitude: 140.916, elevation_base: 430.0, elevation_top: 1126.0 },
  { name_en: 'Geto Kogen Resort (Iwate)', name_ja: '夏油高原スキー場', latitude: 39.201, longitude: 140.852, elevation_base: 400.0, elevation_top: 830.0 }
])
puts "Seeded #{SkiResort.count} ski resorts!"
