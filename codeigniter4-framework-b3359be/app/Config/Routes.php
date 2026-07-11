<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */

// ─── Web routes ───────────────────────────────────────────────────────────────
$routes->get('/', 'Home::index');
$routes->get('api/test', 'Home::test_api');

// ─── Auth API routes ──────────────────────────────────────────────────────────
// Handle CORS preflight (OPTIONS) untuk semua endpoint /api/*
$routes->options('api/(:any)', 'AuthController::options');

// Register & Login
$routes->post('api/register', 'AuthController::register');
$routes->post('api/login',    'AuthController::login');

// User Profile
$routes->get('api/user/(:num)', 'UserController::getProfile/$1');
$routes->post('api/user/update/(:num)', 'UserController::updateProfile/$1');
$routes->delete('api/user/(:num)', 'UserController::deleteUser/$1');

// Admin Reset Password
$routes->post('api/admin/reset-password', 'UserController::adminResetPassword');

// Chat
$routes->get('api/chat/(:num)/(:num)', 'ChatController::getMessages/$1/$2');
$routes->post('api/chat/send', 'ChatController::sendMessage');
$routes->post('api/chat/read/(:num)/(:num)', 'ChatController::readMessages/$1/$2');

// Kontak / Teman
$routes->get('api/kontak/(:num)', 'TemanController::getKontak/$1');
$routes->get('api/friends/accepted/(:num)', 'TemanController::getAcceptedFriends/$1');
$routes->post('api/kontak/add', 'TemanController::addTeman');

// Permintaan Pertemanan (Friend Requests)
$routes->get('api/friends/pending/(:num)', 'TemanController::getIncomingRequests/$1');
$routes->get('api/friends/sent/(:num)',    'TemanController::getSentRequests/$1');
$routes->post('api/friends/add', 'TemanController::addFriendByNim');
$routes->post('api/friends/status', 'TemanController::updateStatus');

// Pencarian Teman
$routes->get('api/my-friends/search/(:num)/(:any)', 'TemanController::searchMyFriends/$1/$2');

// Hapus & Blokir Teman
$routes->delete('api/friends/delete/(:num)/(:num)', 'TemanController::deleteFriend/$1/$2');
$routes->post('api/friends/block', 'TemanController::blacklistFriend');
$routes->get('api/friends/blocked/(:num)', 'TemanController::getBlockedUsers/$1');
$routes->post('api/friends/unblock', 'TemanController::unblockFriend');

// Events
$routes->get('api/events', 'EventController::index');
$routes->get('api/events/(:num)', 'EventController::show/$1'); // Added from remote for compatibility
$routes->post('api/events', 'EventController::createEvent');
$routes->get('api/events/main-active', 'EventController::getMainEvent');
$routes->get('api/events/month/(:num)', 'EventController::getEventsByMonth/$1');
$routes->put('api/events/(:num)', 'EventController::updateEvent/$1');
$routes->delete('api/events/(:num)', 'EventController::deleteEvent/$1');
$routes->post('api/events/main/(:num)', 'EventController::setMainEvent/$1');
