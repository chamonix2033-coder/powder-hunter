resorts = [
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
]

resorts.each do |r_attrs|
  SkiResort.find_or_create_by!(name_ja: r_attrs[:name_ja]) do |resort|
    resort.name_en = r_attrs[:name_en]
    resort.latitude = r_attrs[:latitude]
    resort.longitude = r_attrs[:longitude]
    resort.elevation_base = r_attrs[:elevation_base]
    resort.elevation_top = r_attrs[:elevation_top]
    resort.category = :resort
  end
end

backcountry_routes = [
  { name_ja: '神楽ヶ峰', name_en: 'Kaguragamine', latitude: 36.8402, longitude: 138.7513, elevation_base: 1850, elevation_top: 2028 },
  { name_ja: '黒姫山', name_en: 'Kurohimeyama', latitude: 36.8144, longitude: 138.1341, elevation_base: 1190, elevation_top: 2053 },
  { name_ja: '三ノ沢岳', name_en: 'Sannosawadake', latitude: 35.7533, longitude: 137.8011, elevation_base: 2612, elevation_top: 2846 },
  { name_ja: '剱御前山', name_en: 'Tsurugigozenyama', latitude: 36.5961, longitude: 137.6163, elevation_base: 2450, elevation_top: 2777 },
  { name_ja: '鳥海山', name_en: 'Chokaisan', latitude: 39.0986, longitude: 140.0494, elevation_base: 1200, elevation_top: 2236 },
  { name_ja: '白馬乗鞍岳', name_en: 'Hakuba Norikuradake', latitude: 36.7825, longitude: 137.7944, elevation_base: 1900, elevation_top: 2436 },
  { name_ja: '神奈山', name_en: 'Kannayama', latitude: 36.8900, longitude: 138.1258, elevation_base: 1450, elevation_top: 1909 },
  { name_ja: '前山', name_en: 'Maeyama', latitude: 36.8838, longitude: 138.1405, elevation_base: 1500, elevation_top: 1932 },
  { name_ja: '三田原山', name_en: 'Mitaharayama', latitude: 36.8872, longitude: 138.1158, elevation_base: 1855, elevation_top: 2341 },
  { name_ja: '利尻山', name_en: 'Rishirizan', latitude: 45.1802, longitude: 141.2413, elevation_base: 220, elevation_top: 1721 }
]

backcountry_routes.each do |bc_attrs|
  SkiResort.find_or_create_by!(name_ja: bc_attrs[:name_ja]) do |bc|
    bc.name_en = bc_attrs[:name_en]
    bc.latitude = bc_attrs[:latitude]
    bc.longitude = bc_attrs[:longitude]
    bc.elevation_base = bc_attrs[:elevation_base]
    bc.elevation_top = bc_attrs[:elevation_top]
    bc.category = :backcountry
  end
end

puts "Database seeded: #{SkiResort.count} ski resorts now exist."
