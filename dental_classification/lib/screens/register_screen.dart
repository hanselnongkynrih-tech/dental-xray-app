import 'package:flutter/material.dart';
import '../api/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _role;
  String? _error;
  bool _isLoading = false;
  int _step = 1;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final api = ApiClient();
    try {
      final res = await api.registerUser({
        "full_name": _fullNameController.text,
        "mobile_number": _mobileController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "role": _role,
      });

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context);
      } else {
        setState(() {
          _error = "Registration failed: ${res.body}";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = "Network error: $e";
      });
    }
  }

  Widget _buildRoleSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Select Your Role",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          children: [
            _buildRoleButton('doctor', Icons.local_hospital, Colors.blue),
            _buildRoleButton('patient', Icons.person, Colors.green),
            _buildRoleButton('lab', Icons.science, Colors.deepPurple),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildRoleButton(String role, IconData icon, Color color) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        role[0].toUpperCase() + role.substring(1),
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _role == role
            ? color
            : color.withAlpha((0.7 * 255).round()), // changed here
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        setState(() {
          _role = role;
          _error = null;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() => _step = 2);
        });
      },
    );
  }

  Widget _buildDetailsForm() {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Register as ${_role?[0].toUpperCase()}${_role?.substring(1) ?? ''}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _mobileController,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            onPressed: _register,
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text("Change Role"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _step == 1 ? _buildRoleSelector() : _buildDetailsForm(),
        ),
      ),
    );
  }
}
