#!/bin/bash

# Çıktı dosyası
OUTPUT_FILE="proje_icerikleri.txt"

echo "=== PROJE DOSYALARI İÇERİKLERİ ===" > "$OUTPUT_FILE"
echo "Oluşturma Tarihi: $(date)" >> "$OUTPUT_FILE"
echo "=====================================" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Hariç tutulacak dizinler ve dosyalar
EXCLUDE_DIRS="no_git node_modules .next"
EXCLUDE_FILES=".env .env.local .env.development .env.production package-lock.json"

echo "Hariç tutulan dizinler: $EXCLUDE_DIRS" >> "$OUTPUT_FILE"
echo "Hariç tutulan dosyalar: $EXCLUDE_FILES" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Dosya ekleme fonksiyonu
add_file() {
    local file="$1"
    if [[ -f "$file" && -r "$file" ]]; then
        echo "" >> "$OUTPUT_FILE"
        echo "========================================" >> "$OUTPUT_FILE"
        echo "DOSYA: $file" >> "$OUTPUT_FILE"
        echo "Boyut: $(wc -l < "$file") satır" >> "$OUTPUT_FILE"
        echo "========================================" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # JSON dosyalarını formatlı göster (eğer jq varsa)
        if [[ "$file" == *.json ]] && command -v jq &> /dev/null; then
            jq . "$file" 2>/dev/null >> "$OUTPUT_FILE" || cat "$file" >> "$OUTPUT_FILE"
        else
            cat "$file" >> "$OUTPUT_FILE"
        fi
        
        echo "" >> "$OUTPUT_FILE"
    fi
}

# Önemli dosya listesi
important_files=(
    # Kök dizin dosyaları
    "next.config.js"
    "vercel.json"
    "package.json"
    "README.md"
    "LICENSE"
    "docker-compose.yml"
    "Dockerfile"
    "dockerfile"
    "jsonfig.json"
    ".env.example"
    "project_backup.txt"
    
    # App dizini
    "app/layout.js"
    "app/page.js"
    "app/debug/page.js"
    
    # Lib dizini
    "lib/db.js"
    
    # Database dizini
    "database/setup.sql"
    
    # Scripts dizini
    "scripts/update-countries.js"
)

echo "Önemli dosyalar işleniyor..." | tee -a "$OUTPUT_FILE"

# Önemli dosyaları ekle
for file in "${important_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "Ekleniyor: $file" | tee -a "$OUTPUT_FILE"
        add_file "$file"
    fi
done

# App dizinindeki route.js dosyalarını ekle (özyinelemeli)
echo "" >> "$OUTPUT_FILE"
echo "=== APP DİZİNİ ROUTE.JS DOSYALARI ===" >> "$OUTPUT_FILE"
find app -name "route.js" -type f ! -path "*/.next/*" ! -path "*/node_modules/*" | while read -r file; do
    echo "Ekleniyor: $file" | tee -a "$OUTPUT_FILE"
    add_file "$file"
done

# Components dizinindeki dosyaları ekle
echo "" >> "$OUTPUT_FILE"
echo "=== COMPONENTS DİZİNİ DOSYALARI ===" >> "$OUTPUT_FILE"
if [[ -d "components" ]]; then
    find components -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) \
        ! -path "*/.next/*" ! -path "*/node_modules/*" | while read -r file; do
        echo "Ekleniyor: $file" | tee -a "$OUTPUT_FILE"
        add_file "$file"
    done
fi

# Cron-job dizinindeki dosyaları ekle
echo "" >> "$OUTPUT_FILE"
echo "=== CRON-JOB DİZİNİ DOSYALARI ===" >> "$OUTPUT_FILE"
if [[ -d "cron-job" ]]; then
    find cron-job -type f \( -name "*.js" -o -name "*.py" -o -name "*.sh" \) \
        ! -path "*/.next/*" ! -path "*/node_modules/*" | while read -r file; do
        echo "Ekleniyor: $file" | tee -a "$OUTPUT_FILE"
        add_file "$file"
    done
fi

# Diğer tüm önemli dosyaları bul ve ekle (özyinelemeli)
echo "" >> "$OUTPUT_FILE"
echo "=== DİĞER ÖNEMLİ DOSYALAR ===" >> "$OUTPUT_FILE"
find . -type f \( \
    -name "*.js" -o \
    -name "*.jsx" -o \
    -name "*.ts" -o \
    -name "*.tsx" -o \
    -name "*.json" ! -name "package-lock.json" -o \
    -name "*.md" -o \
    -name "*.txt" -o \
    -name "*.sql" -o \
    -name "*.yml" -o \
    -name "*.yaml" -o \
    -name "*.sh" -o \
    -name "*.config.js" -o \
    -name "*.config.ts" -o \
    -name "Dockerfile" -o \
    -name "dockerfile" -o \
    -name "docker-compose.yml" \
    \) \
    ! -path "./no_git/*" \
    ! -path "./node_modules/*" \
    ! -path "*/.next/*" \
    ! -name ".env" \
    ! -name ".env.local" \
    ! -name ".env.development" \
    ! -name ".env.production" \
    | grep -v "^./.next/" \
    | while read -r file; do
    
    # Zaten eklenmiş dosyaları atla
    already_added=false
    for added_file in "${important_files[@]}"; do
        if [[ "$file" == "./$added_file" ]] || [[ "$file" == "$added_file" ]]; then
            already_added=true
            break
        fi
    done
    
    if ! $already_added && [[ ! "$file" =~ ^./app/.*/route\.js$ ]] && [[ ! "$file" =~ ^./components/ ]] && [[ ! "$file" =~ ^./cron-job/ ]]; then
        echo "Ekleniyor: ${file#./}" | tee -a "$OUTPUT_FILE"
        add_file "$file"
    fi
done

echo "" >> "$OUTPUT_FILE"
echo "=== İŞLEM TAMAMLANDI ===" >> "$OUTPUT_FILE"
echo "Toplam dosya sayısı: $(grep -c "DOSYA:" "$OUTPUT_FILE")" >> "$OUTPUT_FILE"
echo "Çıktı dosyası: $OUTPUT_FILE ($(wc -l < "$OUTPUT_FILE") satır)" >> "$OUTPUT_FILE"

echo ""
echo "✓ İşlem tamamlandı!"
echo "✓ Çıktı dosyası: $OUTPUT_FILE"
echo "✓ Hariç tutulanlar: no_git, node_modules, .next, .env*, package-lock.json"