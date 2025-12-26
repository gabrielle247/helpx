// lib/fix_web.dart
// ignore: unused_import
import 'dart:ui' as ui;

// This provides a compatibility layer for older Stripe packages
// that look for the registry in the wrong place.
void fixStripeRegistry() {
  // We just need the import to trigger the correct compilation path
}