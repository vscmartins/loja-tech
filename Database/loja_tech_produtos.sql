-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: loja_tech
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `produtos`
--

DROP TABLE IF EXISTS `produtos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `produtos` (
  `id_produto` int NOT NULL AUTO_INCREMENT,
  `id_categoria` int NOT NULL,
  `nome` varchar(200) NOT NULL,
  `descricao` text,
  `preco` decimal(10,2) NOT NULL,
  `estoque` int NOT NULL DEFAULT '0',
  `estoque_minimo` int NOT NULL DEFAULT '5',
  `ativo` tinyint(1) DEFAULT '1',
  `criado_em` datetime DEFAULT CURRENT_TIMESTAMP,
  `atualizado_em` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_produto`),
  KEY `fk_produto_categoria` (`id_categoria`),
  CONSTRAINT `fk_produto_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produtos`
--

LOCK TABLES `produtos` WRITE;
/*!40000 ALTER TABLE `produtos` DISABLE KEYS */;
INSERT INTO `produtos` VALUES (1,1,'Notebook Dell Inspiron 15',NULL,3499.90,24,5,1,'2026-11-24 18:13:32','2026-11-24 18:13:33'),(2,1,'Notebook Lenovo IdeaPad 3',NULL,2899.00,18,5,1,'2026-11-24 18:13:32','2026-11-24 18:13:32'),(3,2,'Samsung Galaxy S24',NULL,4299.00,40,10,1,'2026-11-24 18:13:32','2026-11-24 18:13:32'),(4,2,'iPhone 15',NULL,6499.00,15,5,1,'2026-11-24 18:13:32','2026-11-24 18:13:32'),(5,3,'Teclado Mecânico Redragon',NULL,249.90,61,10,1,'2026-11-24 18:13:32','2026-11-24 18:13:33'),(6,3,'Mouse Logitech G502',NULL,349.90,45,10,1,'2026-11-24 18:13:32','2026-11-24 18:13:33'),(7,3,'Headset HyperX Cloud II',NULL,499.90,30,8,1,'2026-11-24 18:13:32','2026-11-24 18:13:32'),(8,4,'Monitor LG UltraWide 29\"',NULL,1599.00,12,3,1,'2026-11-24 18:13:32','2026-11-24 18:13:32'),(9,4,'Monitor Samsung Curvo 27\"',NULL,1899.00,10,3,1,'2026-11-24 18:13:32','2026-11-24 18:13:32'),(10,5,'SSD Kingston 480GB',NULL,219.90,80,15,1,'2026-11-24 18:13:32','2026-11-24 18:13:32'),(11,5,'HD Externo Seagate 1TB',NULL,329.90,35,8,1,'2026-11-24 18:13:32','2026-11-24 18:13:32'),(12,3,'Webcam Logitech C920','Full HD 1080p',399.90,20,5,1,'2026-11-24 18:13:33','2026-11-24 18:13:33');
/*!40000 ALTER TABLE `produtos` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-24 18:31:45
