import importlib.util,struct,unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location('bundle',Path(__file__).with_name('check_bundle.py'));module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
class Checks(unittest.TestCase):
 def test_reads_real_elf64_load_alignment(self):
  data=bytearray(120);data[:6]=b'\x7fELF\x02\x01';struct.pack_into('<Q',data,32,64);struct.pack_into('<HH',data,54,56,1);struct.pack_into('<I',data,64,1);struct.pack_into('<Q',data,112,16384)
  self.assertEqual(module.elf_alignments(data),[16384]);struct.pack_into('<Q',data,112,4096);self.assertEqual(module.elf_alignments(data),[4096])
 def test_empty_profile_cannot_be_published(self):self.assertIn('play_console_account',module.blockers({}));self.assertIn('support_email',module.blockers({}))
 def test_configured_billing_requires_independent_verification(self):self.assertIn('paid_ai_confirmed',module.blockers({'billing_endpoint':'https://test.invalid'}))
 def test_free_infrastructure_does_not_require_paid_ai_when_personal_ai_is_disabled(self):
  missing=module.blockers({'billing_endpoint':'https://test.invalid','personal_ai_enabled':False})
  self.assertNotIn('paid_ai_confirmed',missing);self.assertIn('billing_server_verified',missing);self.assertIn('play_products_verified',missing)
 def test_unpaid_education_requires_data_boundary_review(self):
  self.assertIn('education_privacy_verified',module.blockers({'unpaid_education_enabled':True}))
if __name__=='__main__':unittest.main()
