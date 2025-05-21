import 'package:flutter/material.dart';

class CoffeeShopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16),
              Text(
                'Coffee Shop',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 48),
              Text(
                'Welcome to Coffee Shop',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Order ahead and pick up your favorites',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement Sign Up functionality
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement Sign In functionality
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Spacer(), // push the bottom navigation bar down
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
        ],
      ),
    );
  }
}