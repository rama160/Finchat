"""Create publishable static HTML only after public identity/contact are set."""
import argparse,html,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--profile',required=True);p.add_argument('--output',required=True);a=p.parse_args()
profile=json.loads(Path(a.profile).read_text())
for key in ['publisher','support_email']:
    if not profile.get(key) or any(x in profile[key].lower() for x in ['replace','example.invalid','placeholder']):raise SystemExit('Public identity/contact missing: '+key)
if '@' not in profile['support_email'] or '\n' in profile['support_email']:raise SystemExit('Invalid public support email')
root=Path(__file__).resolve().parents[2];out=Path(a.output);out.mkdir(parents=True,exist_ok=True)
contact=f"Penerbit: {profile['publisher']}\nKontak: {profile['support_email']}"
privacy=(root/'assets/legal/privacy_id.txt').read_text().replace('Identitas penerbit, kontak, URL privasi dan penghapusan harus dilengkapi sebelum aplikasi diterbitkan. Tidak ada kontak pribadi pengguna yang dipublikasikan oleh build persiapan.','Hubungi penerbit melalui kontak yang tercantum di halaman ini.')
delete='''Penghapusan akun dan data Spenva

Anda dapat meminta penghapusan tanpa menginstal ulang aplikasi. Kirim permintaan ke email dukungan di halaman ini dari akun yang terhubung dengan Spenva. Sebutkan bahwa Anda ingin menghapus akun/data Spenva. Jangan kirim sandi Google, nomor kartu atau seluruh database keuangan. Kami akan memverifikasi kepemilikan akun, menjelaskan data yang dapat dihapus, dan menanggapi dalam7 hari kerja. Target penyelesaian30 hari setelah verifikasi; kami akan memberi tahu jika proses membutuhkan waktu lebih lama.

Di aplikasi: Pengaturan → Privasi dan data → Hapus akun dan data. Konfirmasi permanen. Aktifkan pilihan hapus Drive untuk membersihkan backup akun aktif. Profil lain dipertahankan. Backup yang tidak dihapus dapat memulihkan data lokal.

Tanpa aplikasi: pengelola dapat menghapus laporan terkait akun pada server setelah verifikasi. Catatan kuota pseudonim tanpa transaksi/pertanyaan dapat dipertahankan sampai akhir periode langganan ditambah30 hari untuk mencegah penyalahgunaan. Google mengelola catatan pembayarannya sendiri. Backup adalah milik akun Drive Anda: buka Google Drive Settings → Manage apps → Spenva/FinChat → Delete hidden app data. Opsi ini dapat menghapus seluruh backup aplikasi, termasuk profil lokal lain; periksa salinan yang ingin dipertahankan terlebih dahulu. Pengelola tidak bisa masuk ke Drive Anda tanpa izin.

Data lokal yang hanya berada di perangkat tidak dapat dihapus dari jarak jauh. Jika aplikasi masih ada, gunakan menu penghapusan; jika tidak, periksa data aplikasi pada pengaturan Android. PDF, backup ekspor, data pada perangkat lain dan salinan yang dibagikan harus dihapus sendiri. Logout tidak menghapus transaksi.

Penghapusan akun/data tidak membatalkan langganan. Batalkan melalui Google Play → Pembayaran & langganan → Langganan → Spenva. Kuota pembayaran/perpanjangan mengikuti ketentuan Google Play.
'''
for name,text in [('privacy',privacy),('delete-account',delete)]:
    paragraphs=''.join('<p>'+html.escape(x).replace('\n','<br>')+'</p>' for x in (contact+'\n\n'+text).split('\n\n'))
    body='<!doctype html><html lang="id"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Spenva — '+name+'</title><style>body{max-width:760px;margin:36px auto;padding:0 20px;font:17px/1.65 system-ui;color:#22232f;background:#f9f7fd}h1{color:#555d91}a{color:#555d91}p{overflow-wrap:anywhere}</style><h1>Spenva</h1>'+paragraphs+'<p><a href="privacy.html">Privasi</a> · <a href="delete-account.html">Penghapusan data</a></p></html>'
    (out/(name+'.html')).write_text(body)
print('Two public legal pages generated. Review content and confirm support SLA before hosting.')
