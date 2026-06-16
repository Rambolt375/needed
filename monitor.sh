#!/bin/bash

VM2_IP="192.168.56.11"
SSH_USER="han"

echo "=================================================="
echo "       STATUS MONITORING SISTEM WEB HOSTING       "
echo "=================================================="

if systemctl is-active --quiet haproxy; then
    echo "[OK] Service HAProxy lokal berjalan dengan normal."
else
    echo "[CRITICAL] Service HAProxy lokal berhenti atau mengalami error!"
fi

if ping -c 1 -W 2 $VM2_IP &> /dev/null; then
    echo "[OK] Konektivitas jaringan ke VM 2 ($VM2_IP) terhubung."
    
    DOCKER_STATUS=$(ssh -o ConnectTimeout=5 -o BatchMode=yes $SSH_USER@$VM2_IP "docker ps -q | wc -l" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        if [ "${DOCKER_STATUS:-0}" -gt 0 ]; then
            echo "[OK] Terdapat $DOCKER_STATUS kontainer Docker di VM 2 dalam kondisi Up."
        else
            echo "[CRITICAL] Tidak ada kontainer Docker yang berjalan di VM 2!"
        fi
    else
        echo "[CRITICAL] Gagal melakukan remote SSH ke VM 2. Pastikan SSH Key sudah terkonfigurasi untuk passwordless login."
    fi
else
    echo "[CRITICAL] Jaringan ke VM 2 ($VM2_IP) terputus (Request Timeout)!"
    echo "[CRITICAL] Pengecekan kontainer Docker diabaikan karena VM 2 tidak dapat dijangkau."
fi

echo "=================================================="