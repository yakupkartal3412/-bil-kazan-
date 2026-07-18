import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedGiftType = 'diamonds';
  bool _isLoading = false;

  final Map<String, String> _giftTypes = {
    'diamonds': 'Elmas',
    'roomCards': 'Oda Kartı',
    'jokers': 'Joker (Karışık)',
  };

  Future<void> _sendGift() async {
    final uid = _uidController.text.trim();
    final amountText = _amountController.text.trim();

    if (uid.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen tüm alanları doldurun')));
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Geçerli bir miktar girin')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu ID ile kullanıcı bulunamadı!')));
        setState(() => _isLoading = false);
        return;
      }

      // Add to pending_gifts array
      final newGift = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': _selectedGiftType,
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await docRef.update({
        'pending_gifts': FieldValue.arrayUnion([newGift])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hediye başarıyla gönderildi! 🎉'), backgroundColor: Colors.green));
        _amountController.clear();
      }
    } catch (e) {
      debugPrint('Hediye gönderim hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      appBar: AppBar(
        title: const Text('Admin Paneli', style: TextStyle(color: Colors.amberAccent)),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Hediye Gönderim Formu', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _uidController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Kullanıcı ID',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedGiftType,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Hediye Türü',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
              ),
              items: _giftTypes.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedGiftType = val);
                }
              },
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Miktar',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent)),
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _sendGift,
                child: const Text('HEDİYE GÖNDER', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}
