-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 11 Jul 2026 pada 05.27
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `speakapp_db`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `blocked_users`
--

CREATE TABLE `blocked_users` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `blocked_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `chats`
--

CREATE TABLE `chats` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `reply_to_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `chats`
--

INSERT INTO `chats` (`id`, `sender_id`, `receiver_id`, `message`, `created_at`, `reply_to_id`, `is_read`) VALUES
(1, 4, 1, 'haloo', '2025-11-26 12:59:34', NULL, 0),
(16, 9, 5, 'cihuyy', '2025-11-27 08:50:03', NULL, 1),
(17, 9, 8, 'njrilllll', '2025-11-27 09:45:50', NULL, 0),
(18, 9, 8, 'info infaq ', '2025-11-27 09:48:05', NULL, 0),
(19, 9, 8, 'karo absensi', '2025-11-27 09:48:13', NULL, 0),
(20, 8, 9, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse eu lectus dapibus, vulputate diam quis, consequat turpis. Vivamus sem ligula, pretium vel vehicula id, tincidunt sed mi. Phasellus nec urna at ligula laoreet aliquet quis non metus. In a condimentum turpis. Sed pretium faucibus enim non condimentum. Ut sed rhoncus purus. Vestibulum sagittis nisi diam, ut placerat nibh volutpat id. Suspendisse sagittis libero at est porttitor, nec condimentum orci aliquam. Morbi tempor ex nec pulvinar eleifend. Sed neque erat, vulputate vel dapibus quis, maximus sed risus. Nullam luctus tellus in dui congue elementum. Duis congue tincidunt dolor, sed mattis tortor vehicula vel. Vestibulum lectus nisi, sodales sit amet ex quis, pretium elementum ipsum. Vestibulum convallis lectus quis felis feugiat consectetur. Nunc at volutpat mauris. Cras fringilla leo et ligula ornare, dapibus consequat urna gravida.', '2025-11-27 09:49:10', NULL, 0),
(21, 8, 9, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse eu lectus dapibus, vulputate diam quis, consequat turpis. Vivamus sem ligula, pretium vel vehicula id, tincidunt sed mi. Phasellus nec urna at ligula laoreet aliquet quis non metus. In a condimentum turpis. Sed pretium faucibus enim non condimentum. Ut sed rhoncus purus. Vestibulum sagittis nisi diam, ut placerat nibh volutpat id. Suspendisse sagittis libero at est porttitor, nec condimentum orci aliquam. Morbi tempor ex nec pulvinar eleifend. Sed neque erat, vulputate vel dapibus quis, maximus sed risus. Nullam luctus tellus in dui congue elementum. Duis congue tincidunt dolor, sed mattis tortor vehicula vel. Vestibulum lectus nisi, sodales sit amet ex quis, pretium elementum ipsum. Vestibulum convallis lectus quis felis feugiat consectetur. Nunc at volutpat mauris. Cras fringilla leo et ligula ornare, dapibus consequat urna gravida.  Quisque et aliquam massa. Nunc interdum nisl vel diam fermentum, eget placerat mi pretium. Sed sit amet pharetra nibh. Sed sem libero, vulputate vitae magna ac, dapibus dictum quam. Proin at est feugiat, blandit felis quis, dignissim nunc. Vivamus egestas, sapien ut ullamcorper ultrices, felis risus elementum urna, sit amet rutrum nibh ligula nec ipsum. Nullam efficitur sit amet nisi quis posuere. Maecenas nunc dui, vehicula vel lorem sit amet, vestibulum ullamcorper orci. Nunc in arcu arcu. Maecenas non dolor nec dolor euismod luctus. Cras vehicula sed est eleifend maximus. Donec in interdum purus. Vestibulum venenatis commodo sapien, at gravida purus egestas sit amet. Proin interdum pharetra arcu sit amet posuere. Donec nec sollicitudin sem.', '2025-11-27 09:49:58', NULL, 0),
(22, 8, 9, 'adasda', '2025-11-27 09:50:10', NULL, 0),
(23, 8, 9, 'sffsfsfs', '2025-11-27 09:50:16', NULL, 0),
(24, 9, 5, 'eeeee', '2025-11-27 13:18:36', NULL, 1),
(25, 9, 5, 'halo giska', '2025-11-27 13:26:07', NULL, 1),
(29, 5, 9, 'haloo', '2025-11-28 21:57:44', NULL, 0),
(30, 5, 9, 'haloo', '2025-11-28 21:57:44', NULL, 0),
(33, 5, 7, 'yyy', '2025-12-01 10:17:40', NULL, 1),
(34, 5, 9, '.', '2025-12-01 10:20:11', NULL, 0),
(35, 5, 9, '.', '2025-12-01 20:41:43', NULL, 0),
(36, 5, 9, '.', '2025-12-01 20:41:48', NULL, 0),
(37, 5, 9, '.', '2025-12-01 20:41:51', NULL, 0),
(57, 7, 5, 'jhsbkdvjhls', '2025-12-03 17:05:31', NULL, 1),
(58, 5, 7, 'kokokok', '2025-12-03 17:16:11', NULL, 1),
(59, 7, 5, 'pp', '2025-12-03 17:54:25', NULL, 1),
(60, 5, 7, 'pp', '2025-12-03 17:54:46', NULL, 1),
(61, 7, 5, 'pp', '2025-12-03 17:55:11', NULL, 1),
(62, 7, 5, 'ppp', '2025-12-03 17:59:14', NULL, 1),
(63, 5, 7, 'pp', '2025-12-03 18:09:15', NULL, 1),
(64, 5, 7, 'p', '2025-12-03 18:22:46', NULL, 1),
(65, 7, 5, 'kiw', '2025-12-03 18:22:55', NULL, 1),
(66, 5, 7, 'ppp', '2025-12-03 19:12:36', NULL, 1),
(67, 5, 11, 'pp', '2025-12-03 19:44:43', NULL, 1),
(71, 13, 5, 'pp', '2025-12-04 08:12:25', NULL, 1),
(72, 5, 13, 'pp', '2025-12-04 08:12:33', NULL, 1),
(73, 5, 11, '[p', '2025-12-04 08:32:30', NULL, 1),
(74, 13, 5, 'pp', '2025-12-04 08:33:16', NULL, 1),
(75, 13, 5, 'pp', '2025-12-04 08:33:51', NULL, 1),
(76, 13, 5, 'pppppppppppppppppppppppppppppppppp', '2025-12-04 08:34:03', NULL, 1),
(77, 5, 13, 'ttyuioiuogyfukchkvjlucfhgjvigyfuchgvyitfuvjhbk', '2025-12-04 08:34:17', NULL, 1),
(78, 5, 7, 'ppp', '2025-12-08 13:37:46', NULL, 1),
(79, 7, 5, 'pp', '2025-12-08 13:39:27', NULL, 1),
(80, 5, 7, 'pp', '2025-12-08 13:39:34', NULL, 1),
(82, 5, 7, 'cek', '2025-12-09 15:32:27', NULL, 1),
(83, 7, 5, 'cek', '2025-12-09 15:32:40', NULL, 1),
(84, 11, 5, 'cihuyyy', '2025-12-10 08:37:46', NULL, 1),
(85, 7, 5, 'cek', '2025-12-10 08:39:23', NULL, 1),
(86, 5, 7, 'kiw', '2025-12-10 09:25:14', NULL, 1),
(87, 5, 11, 'cihuyyy', '2025-12-10 09:56:14', NULL, 1),
(88, 7, 5, 'kiw', '2025-12-10 03:24:27', NULL, 1),
(89, 7, 5, 'weh', '2025-12-10 04:46:58', NULL, 1),
(90, 7, 5, 'weh', '2025-12-10 04:47:11', NULL, 1),
(91, 7, 5, 'weh', '2025-12-10 04:47:30', NULL, 1),
(92, 7, 5, 'weh', '2025-12-10 04:51:12', NULL, 1),
(93, 11, 5, 'kiw', '2025-12-10 12:00:41', NULL, 1),
(94, 7, 5, 'halo', '2025-12-10 12:01:17', NULL, 1),
(95, 7, 5, 'haloo', '2025-12-10 19:43:00', NULL, 1),
(96, 11, 5, 'hehe', '2025-12-10 19:43:39', NULL, 1),
(97, 5, 7, 'sjdvsjbvlsk', '2025-12-10 19:49:35', NULL, 1),
(98, 7, 5, 'cihuyy', '2025-12-28 10:37:55', NULL, 1),
(99, 5, 7, 'apa banget lah', '2025-12-28 10:38:10', NULL, 1),
(100, 11, 7, 'cihuyy', '2025-12-28 10:44:01', NULL, 1),
(101, 14, 18, 'cihuyyyy', '2026-05-08 11:09:20', NULL, 0),
(102, 20, 14, 'dd', '2026-05-11 02:22:52', NULL, 1),
(103, 14, 20, 'halooo', '2026-05-11 02:23:35', NULL, 1),
(104, 14, 20, 'ppp', '2026-05-11 03:46:27', NULL, 1),
(105, 20, 14, 'cihuyyy', '2026-05-12 08:30:48', NULL, 1),
(106, 14, 20, 'tempe', '2026-05-12 08:31:10', NULL, 1),
(107, 20, 14, 'tahu', '2026-05-12 08:31:14', NULL, 1),
(108, 14, 20, 'ppp', '2026-05-12 08:32:45', NULL, 1),
(109, 14, 20, 'ghi', '2026-05-12 08:34:20', NULL, 1),
(110, 14, 20, 'nnnn', '2026-05-12 08:34:28', NULL, 1),
(111, 14, 20, 'cihuyyyy', '2026-05-12 08:37:32', NULL, 1),
(112, 20, 14, 'apalah', '2026-05-12 08:37:43', NULL, 1),
(113, 14, 20, 'sumpiuh', '2026-05-12 08:39:32', NULL, 1),
(114, 20, 14, 'mmm', '2026-05-12 08:40:02', NULL, 1),
(115, 14, 20, '...', '2026-05-12 08:45:09', NULL, 1),
(116, 14, 20, 'pan', '2026-05-12 08:46:29', NULL, 1),
(117, 21, 20, 'cihuyyy', '2026-07-09 16:16:28', NULL, 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `events`
--

CREATE TABLE `events` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `image` varchar(255) NOT NULL,
  `event_date` date NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `event_link` varchar(255) DEFAULT NULL,
  `is_main` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `events`
--

INSERT INTO `events` (`id`, `title`, `description`, `image`, `event_date`, `created_at`, `event_link`, `is_main`) VALUES
(7, 'MLBB Campoinship', 'Ini adalah puncak kompetisi Mobile Legends tahun 2025. Turnamen ini dirancang sebagai perayaan komunitas game mobile terbesar, menggabungkan kompetisi tingkat profesional tertinggi dengan kemegahan produksi acara hiburan skala stadion.', 'MLBB.png', '2025-10-15', '2025-11-27 19:06:50', 'https://www.instagram.com/mpl.id.official/?hl=id', 0),
(10, 'lomba live coding', 'cihuyyyy', 'lomba_live_coding.png', '2025-02-12', '2025-12-03 09:48:38', 'https://www.instagram.com/p/DRs5kCtkiFN/?igsh=MXQ0dzkxNjcwd2cwYQ%3D%3D', 0),
(12, 'ukyjfthghgh', 'rfgrthyjgukhijkjhugyjf', '1783668626_4f7d4be5dc873109ef3d.png', '2026-06-26', '2026-07-10 14:30:26', 'https://www.figma.com/design/hxUojjm4deqVUOOx0ghJWL/SpeakApp?node-id=0-1&p=f', 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `friends`
--

CREATE TABLE `friends` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `friend_id` int(11) NOT NULL,
  `status` enum('pending','accepted','blocked') DEFAULT 'accepted',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `friends`
--

INSERT INTO `friends` (`id`, `user_id`, `friend_id`, `status`, `created_at`) VALUES
(9, 8, 7, 'accepted', '2025-11-27 08:30:20'),
(12, 9, 5, 'accepted', '2025-11-27 08:45:03'),
(13, 9, 8, 'accepted', '2025-11-27 09:45:37'),
(14, 8, 9, 'accepted', '2025-11-27 09:47:45'),
(15, 9, 7, 'accepted', '2025-11-27 13:05:04'),
(16, 5, 9, 'accepted', '2025-11-27 13:19:25'),
(27, 5, 7, 'accepted', '2025-12-03 17:04:35'),
(28, 13, 5, 'accepted', '2025-12-04 08:11:53'),
(29, 7, 11, 'accepted', '2025-12-09 15:34:21'),
(30, 5, 11, 'accepted', '2025-12-09 15:40:39'),
(58, 18, 14, 'accepted', '2026-05-08 06:41:30'),
(59, 19, 14, 'accepted', '2026-05-08 10:41:06'),
(60, 20, 14, 'accepted', '2026-05-11 02:20:41'),
(61, 19, 20, 'accepted', '2026-05-11 02:24:42'),
(62, 21, 5, 'pending', '2026-07-09 15:52:35'),
(63, 21, 20, 'accepted', '2026-07-09 15:59:48'),
(64, 20, 5, 'pending', '2026-07-11 03:10:49');

-- --------------------------------------------------------

--
-- Struktur dari tabel `migrations`
--

CREATE TABLE `migrations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `version` varchar(255) NOT NULL,
  `class` varchar(255) NOT NULL,
  `group` varchar(255) NOT NULL,
  `namespace` varchar(255) NOT NULL,
  `time` int(11) NOT NULL,
  `batch` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `migrations`
--

INSERT INTO `migrations` (`id`, `version`, `class`, `group`, `namespace`, `time`, `batch`) VALUES
(1, '2026-07-10-080255', 'App\\Database\\Migrations\\AddIsMainToEvents', 'default', 'App', 1783670724, 1);

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `nim` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(100) NOT NULL,
  `semester` varchar(5) DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `profile_pic` varchar(255) DEFAULT 'default.png',
  `role` varchar(20) DEFAULT 'mahasiswa',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `nim`, `password`, `name`, `semester`, `gender`, `bio`, `profile_pic`, `role`, `created_at`, `updated_at`) VALUES
(5, '240302024', '$2y$10$eOywpBFB9v9Mw4zBqdF0xeYGYS2kQE8Rbt3IWVTRJtr11GBjVpSQy', 'nur ifant ristanto', '3', 'female', NULL, '1783734781_12b85c716dfa9d803e35.jpg', 'admin', '2025-11-26 06:05:04', '2026-07-11 01:53:01'),
(7, '240302026', '$2y$10$glfnWHo5ctKsHJzVOfT0BeGPcz5l272VXlkgUrtpw7eQZpMML/lFu', 'bambang', '6', 'Laki-laki', NULL, '1764207820_23d90d70b6fc98a64f96.jpg', 'mahasiswa', '2025-11-26 13:37:59', '2025-11-27 01:43:40'),
(8, '09876', '$2y$10$j0YpEMZuAwt2HINACBxndetqBABIO4WWBLJ4HywoTd2I6lxRbtUJq', 'nazril', '5', 'Laki-laki', '-', '1764206966_1d2538c8bd1331d19dc4.png', 'mahasiswa', '2025-11-26 14:00:08', '2025-11-27 01:29:26'),
(9, '12345', '$2y$10$xvQYg/fxQTTiDxCsU7NLHeS8WFZYAOhG1TwIA43nal.yz8v7IQjla', 'bagas', '15', 'Laki-laki', '-', '1764224910_efc4e490e81040ada422.jpeg', 'mahasiswa', '2025-11-27 01:44:34', '2025-11-27 06:28:51'),
(11, '2402020', '$2y$10$zetMjQSrnXjFKoyMNCv3A.xlpt15mW7l3ePmnvG0udrsSi.NIQVy2', 'Giland ', '5', 'Laki-laki', '-', '1765248359_bce605656c52ac005bac.jpg', 'mahasiswa', '2025-12-03 03:16:01', '2025-12-09 02:45:59'),
(13, '121212', '$2y$10$oCwtRv.c7cJxIwtp./uKJeFQ483pnFWpGwpnhMHa2bPiN/7l6oe6C', 'bagas', '4', 'male', '-', '1781013170_8949d25674806ea0b16f.jpg', 'mahasiswa', '2025-12-04 01:11:36', '2026-06-09 13:52:50'),
(14, '101010', '$2y$10$WGEX9IndZos1bKCx8dZWHeawN/3K.l/OL//7Bn1MwnnF2ytrdsfc6', 'ifant', '4', 'male', NULL, 'default.png', 'user', '2026-05-08 03:48:08', '2026-05-08 03:48:08'),
(18, '44444444', '$2y$10$X/r65jEFaOTWwjdXGlJa7e3tDjKwXRivI0vT0ftN4P9wTbZ1QUuba', 'ipant2', '5', 'male', NULL, 'default.png', 'user', '2026-05-08 05:46:02', '2026-05-08 05:46:02'),
(19, '2000', '$2y$10$HBd9Gi6.lDDTx8HEZ2d7a.DOTNIkc2PT0fBxdYmqN2BTHhRNq4ztG', 'dika', '4', 'male', NULL, 'default.png', 'user', '2026-05-08 10:40:43', '2026-05-08 10:40:43'),
(20, '123123', '$2y$10$CzRrL.OsvAI2ZV5ZA2bvJuOgreCtwHydp5rmcWzasa1HzES1QPx2m', 'bagas', '6', 'female', NULL, '1783735315_24ebc68b70cc5c6f3bc8.jpg', 'user', '2026-05-11 02:20:23', '2026-07-11 02:01:55'),
(21, '55555', '$2y$10$b2ocScmr6p6rY8omNn0jFOurCgUDA1ug88qqlHrbwL0TEEAYsAzdW', 'ipancihuyy', '4', 'male', NULL, '1783598982_c7c810699cd8414acab5.jpg', 'admin', '2026-07-09 09:52:23', '2026-07-10 08:57:17');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `blocked_users`
--
ALTER TABLE `blocked_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_block` (`user_id`,`blocked_id`),
  ADD KEY `blocked_id` (`blocked_id`);

--
-- Indeks untuk tabel `chats`
--
ALTER TABLE `chats`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `friends`
--
ALTER TABLE `friends`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_friendship` (`user_id`,`friend_id`),
  ADD KEY `friend_id` (`friend_id`);

--
-- Indeks untuk tabel `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nim` (`nim`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `blocked_users`
--
ALTER TABLE `blocked_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT untuk tabel `chats`
--
ALTER TABLE `chats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT untuk tabel `events`
--
ALTER TABLE `events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `friends`
--
ALTER TABLE `friends`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT untuk tabel `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `blocked_users`
--
ALTER TABLE `blocked_users`
  ADD CONSTRAINT `blocked_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `blocked_users_ibfk_2` FOREIGN KEY (`blocked_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `friends`
--
ALTER TABLE `friends`
  ADD CONSTRAINT `friends_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `friends_ibfk_2` FOREIGN KEY (`friend_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
