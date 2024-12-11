-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- 主機： 127.0.0.1:3306
-- 產生時間： 2024-11-02 06:36:08
-- 伺服器版本： 11.2.2-MariaDB
-- PHP 版本： 8.2.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 資料庫： `gogoapp`
--
CREATE DATABASE IF NOT EXISTS `gogoapp` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `gogoapp`;

-- --------------------------------------------------------

--
-- 資料表結構 `dishes`
--

DROP TABLE IF EXISTS `dishes`;
CREATE TABLE IF NOT EXISTS `dishes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `profession_tag` varchar(255) DEFAULT NULL,
  `recipe` text DEFAULT NULL,
  `type` enum('素','肉') DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `dishes`
--

INSERT INTO `dishes` (`id`, `name`, `profession_tag`, `recipe`, `type`) VALUES
(1, '麻婆豆腐', '中式', '豆腐和肉末炒制', '素'),
(2, '宫保鸡丁', '中式', '鸡肉、花生、辣椒炒制', '肉'),
(3, '红烧茄子', '中式', '茄子红烧', '素'),
(4, '鱼香肉丝', '中式', '猪肉丝和蔬菜炒制', '肉');

-- --------------------------------------------------------

--
-- 資料表結構 `dish_products`
--

DROP TABLE IF EXISTS `dish_products`;
CREATE TABLE IF NOT EXISTS `dish_products` (
  `dish_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  PRIMARY KEY (`dish_id`,`product_id`),
  KEY `product_id` (`product_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `dish_products`
--

INSERT INTO `dish_products` (`dish_id`, `product_id`) VALUES
(1, 1),
(1, 2),
(2, 1),
(3, 5),
(4, 7);

-- --------------------------------------------------------

--
-- 資料表結構 `images`
--

DROP TABLE IF EXISTS `images`;
CREATE TABLE IF NOT EXISTS `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `images`
--

INSERT INTO `images` (`id`, `url`) VALUES
(1, 'https://i.imgur.com/m215dRS.png'),
(2, 'https://photos.app.goo.gl/B4wt8XMrVUooSQPz6'),
(3, 'https://imgur.com/a/kXDS0rs');

-- --------------------------------------------------------

--
-- 資料表結構 `products`
--

DROP TABLE IF EXISTS `products`;
CREATE TABLE IF NOT EXISTS `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_url` varchar(255) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  `stock` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `products`
--

INSERT INTO `products` (`id`, `image_url`, `name`, `description`, `price`, `category`, `tags`, `stock`) VALUES
(1, 'https://i.imgur.com/KTsDJhN.png', '米', '米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米米', 19.99, 'Category 1', 'off', 0),
(2, 'https://i.imgur.com/rhaW7Iy.jpeg', '鷄蛋', '鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋鷄蛋', 29.99, 'Category 1', 'off', 50),
(3, 'https://i.imgur.com/ZIrP97I.png', 'Product 3', 'Description for product 3', 39.99, 'Category 2', 'off', 75),
(4, 'https://firebasestorage.googleapis.com/v0/b/lifeapp-bb6a4.appspot.com/o/e7b512c817aa32784deaa5a8222e955.png?alt=media&token=649e662d-9f05-4dea-a90a-3278a9e04532', 'Product 4', 'Description for product 4', 49.99, 'Category 2', 'off', 20),
(5, 'https://firebasestorage.googleapis.com/v0/b/lifeapp-bb6a4.appspot.com/o/dd8b635bc9ece27f4fb218e161c8847.png?alt=media&token=463c9709-9107-4f28-a3e8-b4b0e1a34795', 'Product 5', 'Description for product 5', 59.99, 'Category 3', 'off', 30),
(6, 'https://firebasestorage.googleapis.com/v0/b/lifeapp-bb6a4.appspot.com/o/60d07c7f38c0a6acbb1a11e1664986e.png?alt=media&token=cc5f07d1-0cec-484e-b3ba-9381613fb464', 'Product 6', 'Description for product 6', 69.99, 'Category 3', 'tag2', 0),
(7, 'https://firebasestorage.googleapis.com/v0/b/lifeapp-bb6a4.appspot.com/o/8a89d1610ee879f26439f9a1309ae92.png?alt=media&token=bed9cb0c-cdb2-434e-aba0-f707c10c874a', 'Product 7', 'Description for product 7', 79.99, 'Category 4', 'tag2', 90),
(8, 'https://firebasestorage.googleapis.com/v0/b/lifeapp-bb6a4.appspot.com/o/60d07c7f38c0a6acbb1a11e1664986e.png?alt=media&token=cc5f07d1-0cec-484e-b3ba-9381613fb464', 'Product 8', 'Description for product 8', 89.99, 'Category 4', 'tag2', 10);

-- --------------------------------------------------------

--
-- 資料表結構 `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `password` varchar(255) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `job` varchar(255) DEFAULT NULL,
  `gender` enum('male','female','women') DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- 傾印資料表的資料 `users`
--

INSERT INTO `users` (`id`, `password`, `name`, `email`, `phone`, `job`, `gender`) VALUES
(1, '$2y$10$HLUpUfDal.ttzw0cazk7a.6Dpm0jK6X3ngUgoz3NERZtV1qk9CT9i', '51123043', '', NULL, NULL, 'male'),
(12, '$2a$10$wXgvUirRSc4latwKLIZDK./1KuLW1ciu9/gWB9SjfDYucAfXGp5xa', '6113770', '958893732@QQ.COM', '4156454', '打工仔', 'male'),
(11, '$2a$10$q4wd2LIkpoFokW3qSFOiYOT4tmY.9wgdPXYK8JpPniJnDV9aUXiRG', '21231231', '486548564@gnm.com', '51123043', '家庭主婦', 'women'),
(10, '$2a$10$OJOfWV2Un8MNEC9RMxZ8ru1YG7HPJazUopq5V0F/UinqrFiBtR6R2', '411524', '4154156456@gma.com', '51123043', '家庭主婦', 'women'),
(9, '$2a$10$5l576iQD2RFO6FFb7mGAAuY2u8sirjMth0w/7fQQNpJgaEfZpYdcW', 'dasfdag', '941654856@qq.com', '511230423', '打工仔', 'women'),
(8, '$2a$10$TE1VHwNpDJKnTzR2WtHfOubUc5f6d51RUkdXiizmmBDjXcQ7aVIYi', 'dasfa', '958893732@qq.com', '51123043', '家庭主妇', 'male');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
