--
-- PostgreSQL database dump
--

-- Dumped from database version 16.0
-- Dumped by pg_dump version 16.0

-- Started on 2023-12-25 17:14:37

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 251 (class 1255 OID 74475)
-- Name: calculate_order_total(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_order_total(order_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
  total DECIMAL;
BEGIN
  SELECT SUM("Miktar" * "BirimFiyat") INTO total
  FROM "SiparişDetayları"
  WHERE "SiparişID" = order_id;

  RETURN total;
END;
$$;


ALTER FUNCTION public.calculate_order_total(order_id integer) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 74520)
-- Name: insert_statistics_on_sale(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_statistics_on_sale() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Satış yapılan tarih için bir kayıt var mı kontrol et
  IF NOT EXISTS (SELECT 1 FROM "İstatistikler" WHERE "Tarih" = NEW."Tarih") THEN
    -- Eğer kayıt yoksa, yeni bir kayıt ekle
    INSERT INTO "İstatistikler" ("Tarih", "SatışAdedi", "Gelir")
    VALUES (NEW."Tarih", 1, NEW."ToplamTutar");
  ELSE
    -- Eğer kayıt varsa, mevcut kaydı güncelle
    UPDATE "İstatistikler"
    SET "SatışAdedi" = "SatışAdedi" + 1,
        "Gelir" = "Gelir" + NEW."ToplamTutar"
    WHERE "Tarih" = NEW."Tarih";
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_statistics_on_sale() OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 74501)
-- Name: list_products_by_category(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.list_products_by_category(category_name character varying) RETURNS TABLE(product_name character varying, product_price numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT "ÜrünAdı" AS product_name, "Fiyat" AS product_price
  FROM "Ürünler"
  WHERE "KategoriID" = (SELECT "KategoriID" FROM "Kategoriler" WHERE "KategoriAdı" = category_name);

  RETURN;
END;
$$;


ALTER FUNCTION public.list_products_by_category(category_name character varying) OWNER TO postgres;

--
-- TOC entry 255 (class 1255 OID 74502)
-- Name: list_sales_before_date(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.list_sales_before_date(target_date date) RETURNS TABLE(sale_id integer, sale_date date)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT "SatışID" AS sale_id, "Tarih" AS sale_date
  FROM "Satışlar"
  WHERE "Tarih" < target_date;

  RETURN;
END;
$$;


ALTER FUNCTION public.list_sales_before_date(target_date date) OWNER TO postgres;

--
-- TOC entry 257 (class 1255 OID 74516)
-- Name: log_stock_empty(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.log_stock_empty() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW."StokMiktarı" = 0 THEN
    -- Stok tükendiğinde log kaydı oluştur
    INSERT INTO "StokLog" ("ÜrünID", "Tarih", "Mesaj")
    VALUES (NEW."ÜrünID", CURRENT_TIMESTAMP, NEW."ÜrünAdı" || ' stokları tükendi!');
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_stock_empty() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 74317)
-- Name: Siparişler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Siparişler" (
    "SiparişID" integer NOT NULL,
    "MüşteriID" integer,
    "Tarih" date,
    "ToplamTutar" numeric,
    "Durum" character varying
);


ALTER TABLE public."Siparişler" OWNER TO postgres;

--
-- TOC entry 256 (class 1255 OID 74506)
-- Name: update_order_status(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_order_status(order_id integer, new_status character varying) RETURNS SETOF public."Siparişler"
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Sipariş durumunu güncelle
  UPDATE "Siparişler"
  SET "Durum" = new_status
  WHERE "SiparişID" = order_id;

  -- Güncellenmiş sipariş bilgilerini döndür
  RETURN QUERY
  SELECT * FROM "Siparişler"
  WHERE "SiparişID" = order_id;
END;
$$;


ALTER FUNCTION public.update_order_status(order_id integer, new_status character varying) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 74493)
-- Name: update_order_total_on_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_order_total_on_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE "Siparişler"
  SET "ToplamTutar" = calculate_order_total(NEW."SiparişID")
  WHERE "SiparişID" = NEW."SiparişID";

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_order_total_on_insert() OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 74499)
-- Name: update_return_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_return_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE "İadeTalepleri"
  SET "Durum" = 'İnceleniyor'
  WHERE "SiparişID" = NEW."SiparişID";

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_return_status() OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 74454)
-- Name: Garanti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Garanti" (
    "GarantiID" integer NOT NULL,
    "ÜrünID" integer,
    "BaşlangıçTarihi" date,
    "BitişTarihi" date,
    "GarantiDurumu" character varying(255)
);


ALTER TABLE public."Garanti" OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 74453)
-- Name: Garanti_GarantiID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Garanti_GarantiID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Garanti_GarantiID_seq" OWNER TO postgres;

--
-- TOC entry 4969 (class 0 OID 0)
-- Dependencies: 237
-- Name: Garanti_GarantiID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Garanti_GarantiID_seq" OWNED BY public."Garanti"."GarantiID";


--
-- TOC entry 216 (class 1259 OID 74287)
-- Name: Kategoriler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Kategoriler" (
    "KategoriID" integer NOT NULL,
    "KategoriAdı" character varying(255)
);


ALTER TABLE public."Kategoriler" OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 74286)
-- Name: Kategoriler_KategoriID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Kategoriler_KategoriID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Kategoriler_KategoriID_seq" OWNER TO postgres;

--
-- TOC entry 4970 (class 0 OID 0)
-- Dependencies: 215
-- Name: Kategoriler_KategoriID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Kategoriler_KategoriID_seq" OWNED BY public."Kategoriler"."KategoriID";


--
-- TOC entry 250 (class 1259 OID 90208)
-- Name: Kullanici; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Kullanici" (
    "KullaniciID" integer NOT NULL,
    "kullaniciAdi" character varying NOT NULL,
    "kullaniciSifre" character varying NOT NULL
);


ALTER TABLE public."Kullanici" OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 90207)
-- Name: Kullanici_KullaniciID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Kullanici_KullaniciID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Kullanici_KullaniciID_seq" OWNER TO postgres;

--
-- TOC entry 4971 (class 0 OID 0)
-- Dependencies: 249
-- Name: Kullanici_KullaniciID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Kullanici_KullaniciID_seq" OWNED BY public."Kullanici"."KullaniciID";


--
-- TOC entry 224 (class 1259 OID 74359)
-- Name: MüşteriAdresleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."MüşteriAdresleri" (
    "AdresID" integer NOT NULL,
    "MüşteriID" integer,
    "Adres" character varying(255)
);


ALTER TABLE public."MüşteriAdresleri" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 74358)
-- Name: MüşteriAdresleri_AdresID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."MüşteriAdresleri_AdresID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."MüşteriAdresleri_AdresID_seq" OWNER TO postgres;

--
-- TOC entry 4972 (class 0 OID 0)
-- Dependencies: 223
-- Name: MüşteriAdresleri_AdresID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."MüşteriAdresleri_AdresID_seq" OWNED BY public."MüşteriAdresleri"."AdresID";


--
-- TOC entry 248 (class 1259 OID 82076)
-- Name: Müşteriler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Müşteriler" (
    "müşteri_id" integer NOT NULL,
    telefon character varying(20),
    "kişi_id" integer
);


ALTER TABLE public."Müşteriler" OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 82075)
-- Name: Müşteriler_müşteri_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Müşteriler_müşteri_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Müşteriler_müşteri_id_seq" OWNER TO postgres;

--
-- TOC entry 4973 (class 0 OID 0)
-- Dependencies: 247
-- Name: Müşteriler_müşteri_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Müşteriler_müşteri_id_seq" OWNED BY public."Müşteriler"."müşteri_id";


--
-- TOC entry 232 (class 1259 OID 74412)
-- Name: Satıcılar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Satıcılar" (
    "SatıcıID" integer NOT NULL,
    "Ad" character varying(255),
    "Soyad" character varying(255),
    "MağazaAdı" character varying(255)
);


ALTER TABLE public."Satıcılar" OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 74411)
-- Name: Satıcılar_SatıcıID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Satıcılar_SatıcıID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Satıcılar_SatıcıID_seq" OWNER TO postgres;

--
-- TOC entry 4974 (class 0 OID 0)
-- Dependencies: 231
-- Name: Satıcılar_SatıcıID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Satıcılar_SatıcıID_seq" OWNED BY public."Satıcılar"."SatıcıID";


--
-- TOC entry 226 (class 1259 OID 74371)
-- Name: Satışlar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Satışlar" (
    "SatışID" integer NOT NULL,
    "ÇalışanID" integer,
    "SiparişID" integer,
    "Tarih" date,
    "ToplamTutar" numeric
);


ALTER TABLE public."Satışlar" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 74370)
-- Name: Satışlar_SatışID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Satışlar_SatışID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Satışlar_SatışID_seq" OWNER TO postgres;

--
-- TOC entry 4975 (class 0 OID 0)
-- Dependencies: 225
-- Name: Satışlar_SatışID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Satışlar_SatışID_seq" OWNED BY public."Satışlar"."SatışID";


--
-- TOC entry 222 (class 1259 OID 74331)
-- Name: SiparişDetayları; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SiparişDetayları" (
    "DetayID" integer NOT NULL,
    "SiparişID" integer,
    "ÜrünID" integer,
    "Miktar" integer,
    "BirimFiyat" numeric
);


ALTER TABLE public."SiparişDetayları" OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 74330)
-- Name: SiparişDetayları_DetayID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."SiparişDetayları_DetayID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."SiparişDetayları_DetayID_seq" OWNER TO postgres;

--
-- TOC entry 4976 (class 0 OID 0)
-- Dependencies: 221
-- Name: SiparişDetayları_DetayID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."SiparişDetayları_DetayID_seq" OWNED BY public."SiparişDetayları"."DetayID";


--
-- TOC entry 219 (class 1259 OID 74316)
-- Name: Siparişler_SiparişID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Siparişler_SiparişID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Siparişler_SiparişID_seq" OWNER TO postgres;

--
-- TOC entry 4977 (class 0 OID 0)
-- Dependencies: 219
-- Name: Siparişler_SiparişID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Siparişler_SiparişID_seq" OWNED BY public."Siparişler"."SiparişID";


--
-- TOC entry 242 (class 1259 OID 74508)
-- Name: StokLog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."StokLog" (
    "LogID" integer NOT NULL,
    "ÜrünID" integer,
    "Tarih" timestamp without time zone,
    "Mesaj" text
);


ALTER TABLE public."StokLog" OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 74507)
-- Name: StokLog_LogID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."StokLog_LogID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."StokLog_LogID_seq" OWNER TO postgres;

--
-- TOC entry 4978 (class 0 OID 0)
-- Dependencies: 241
-- Name: StokLog_LogID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."StokLog_LogID_seq" OWNED BY public."StokLog"."LogID";


--
-- TOC entry 236 (class 1259 OID 74435)
-- Name: Yorumlar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Yorumlar" (
    "YorumID" integer NOT NULL,
    "ÜrünID" integer,
    "MüşteriID" integer,
    "YorumMetni" text,
    "Puan" integer
);


ALTER TABLE public."Yorumlar" OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 74434)
-- Name: Yorumlar_YorumID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Yorumlar_YorumID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Yorumlar_YorumID_seq" OWNER TO postgres;

--
-- TOC entry 4979 (class 0 OID 0)
-- Dependencies: 235
-- Name: Yorumlar_YorumID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Yorumlar_YorumID_seq" OWNED BY public."Yorumlar"."YorumID";


--
-- TOC entry 244 (class 1259 OID 82052)
-- Name: kişi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."kişi" (
    "kişi_id" integer NOT NULL,
    ad character varying(50),
    soyad character varying(50),
    email character varying(100)
);


ALTER TABLE public."kişi" OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 82051)
-- Name: kişi_kişi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."kişi_kişi_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."kişi_kişi_id_seq" OWNER TO postgres;

--
-- TOC entry 4980 (class 0 OID 0)
-- Dependencies: 243
-- Name: kişi_kişi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."kişi_kişi_id_seq" OWNED BY public."kişi"."kişi_id";


--
-- TOC entry 246 (class 1259 OID 82059)
-- Name: Çalışan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Çalışan" (
    "çalışan_id" integer NOT NULL,
    pozisyon character varying(50),
    "kişi_id" integer
);


ALTER TABLE public."Çalışan" OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 82058)
-- Name: Çalışan_çalışan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Çalışan_çalışan_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Çalışan_çalışan_id_seq" OWNER TO postgres;

--
-- TOC entry 4981 (class 0 OID 0)
-- Dependencies: 245
-- Name: Çalışan_çalışan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Çalışan_çalışan_id_seq" OWNED BY public."Çalışan"."çalışan_id";


--
-- TOC entry 228 (class 1259 OID 74388)
-- Name: ÖdemeYöntemleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ÖdemeYöntemleri" (
    "ÖdemeID" integer NOT NULL,
    "MüşteriID" integer,
    "Tür" character varying(255),
    "KartNumarası" character varying(20)
);


ALTER TABLE public."ÖdemeYöntemleri" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 74387)
-- Name: ÖdemeYöntemleri_ÖdemeID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ÖdemeYöntemleri_ÖdemeID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ÖdemeYöntemleri_ÖdemeID_seq" OWNER TO postgres;

--
-- TOC entry 4982 (class 0 OID 0)
-- Dependencies: 227
-- Name: ÖdemeYöntemleri_ÖdemeID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ÖdemeYöntemleri_ÖdemeID_seq" OWNED BY public."ÖdemeYöntemleri"."ÖdemeID";


--
-- TOC entry 218 (class 1259 OID 74294)
-- Name: Ürünler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Ürünler" (
    "ÜrünID" integer NOT NULL,
    "ÜrünAdı" character varying(255),
    "KategoriID" integer,
    "Fiyat" numeric,
    "StokMiktarı" integer
);


ALTER TABLE public."Ürünler" OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 74293)
-- Name: Ürünler_ÜrünID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Ürünler_ÜrünID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Ürünler_ÜrünID_seq" OWNER TO postgres;

--
-- TOC entry 4983 (class 0 OID 0)
-- Dependencies: 217
-- Name: Ürünler_ÜrünID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Ürünler_ÜrünID_seq" OWNED BY public."Ürünler"."ÜrünID";


--
-- TOC entry 230 (class 1259 OID 74400)
-- Name: İadeTalepleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."İadeTalepleri" (
    "İadeID" integer NOT NULL,
    "SiparişID" integer,
    "Tarih" date,
    "Durum" character varying(255)
);


ALTER TABLE public."İadeTalepleri" OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 74399)
-- Name: İadeTalepleri_İadeID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."İadeTalepleri_İadeID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."İadeTalepleri_İadeID_seq" OWNER TO postgres;

--
-- TOC entry 4984 (class 0 OID 0)
-- Dependencies: 229
-- Name: İadeTalepleri_İadeID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."İadeTalepleri_İadeID_seq" OWNED BY public."İadeTalepleri"."İadeID";


--
-- TOC entry 234 (class 1259 OID 74421)
-- Name: İndirimler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."İndirimler" (
    "İndirimID" integer NOT NULL,
    "ÜrünID" integer,
    "İndirimOranı" numeric,
    "BaşlangıçTarihi" date,
    "BitişTarihi" date
);


ALTER TABLE public."İndirimler" OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 74420)
-- Name: İndirimler_İndirimID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."İndirimler_İndirimID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."İndirimler_İndirimID_seq" OWNER TO postgres;

--
-- TOC entry 4985 (class 0 OID 0)
-- Dependencies: 233
-- Name: İndirimler_İndirimID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."İndirimler_İndirimID_seq" OWNED BY public."İndirimler"."İndirimID";


--
-- TOC entry 240 (class 1259 OID 74466)
-- Name: İstatistikler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."İstatistikler" (
    "İstatistikID" integer NOT NULL,
    "Tarih" date,
    "SatışAdedi" integer,
    "Gelir" numeric
);


ALTER TABLE public."İstatistikler" OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 74465)
-- Name: İstatistikler_İstatistikID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."İstatistikler_İstatistikID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."İstatistikler_İstatistikID_seq" OWNER TO postgres;

--
-- TOC entry 4986 (class 0 OID 0)
-- Dependencies: 239
-- Name: İstatistikler_İstatistikID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."İstatistikler_İstatistikID_seq" OWNED BY public."İstatistikler"."İstatistikID";


--
-- TOC entry 4722 (class 2604 OID 74457)
-- Name: Garanti GarantiID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Garanti" ALTER COLUMN "GarantiID" SET DEFAULT nextval('public."Garanti_GarantiID_seq"'::regclass);


--
-- TOC entry 4711 (class 2604 OID 74290)
-- Name: Kategoriler KategoriID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kategoriler" ALTER COLUMN "KategoriID" SET DEFAULT nextval('public."Kategoriler_KategoriID_seq"'::regclass);


--
-- TOC entry 4728 (class 2604 OID 90211)
-- Name: Kullanici KullaniciID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kullanici" ALTER COLUMN "KullaniciID" SET DEFAULT nextval('public."Kullanici_KullaniciID_seq"'::regclass);


--
-- TOC entry 4715 (class 2604 OID 74362)
-- Name: MüşteriAdresleri AdresID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MüşteriAdresleri" ALTER COLUMN "AdresID" SET DEFAULT nextval('public."MüşteriAdresleri_AdresID_seq"'::regclass);


--
-- TOC entry 4727 (class 2604 OID 82079)
-- Name: Müşteriler müşteri_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Müşteriler" ALTER COLUMN "müşteri_id" SET DEFAULT nextval('public."Müşteriler_müşteri_id_seq"'::regclass);


--
-- TOC entry 4719 (class 2604 OID 74415)
-- Name: Satıcılar SatıcıID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Satıcılar" ALTER COLUMN "SatıcıID" SET DEFAULT nextval('public."Satıcılar_SatıcıID_seq"'::regclass);


--
-- TOC entry 4716 (class 2604 OID 74374)
-- Name: Satışlar SatışID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Satışlar" ALTER COLUMN "SatışID" SET DEFAULT nextval('public."Satışlar_SatışID_seq"'::regclass);


--
-- TOC entry 4714 (class 2604 OID 74334)
-- Name: SiparişDetayları DetayID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SiparişDetayları" ALTER COLUMN "DetayID" SET DEFAULT nextval('public."SiparişDetayları_DetayID_seq"'::regclass);


--
-- TOC entry 4713 (class 2604 OID 74320)
-- Name: Siparişler SiparişID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Siparişler" ALTER COLUMN "SiparişID" SET DEFAULT nextval('public."Siparişler_SiparişID_seq"'::regclass);


--
-- TOC entry 4724 (class 2604 OID 74511)
-- Name: StokLog LogID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StokLog" ALTER COLUMN "LogID" SET DEFAULT nextval('public."StokLog_LogID_seq"'::regclass);


--
-- TOC entry 4721 (class 2604 OID 74438)
-- Name: Yorumlar YorumID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yorumlar" ALTER COLUMN "YorumID" SET DEFAULT nextval('public."Yorumlar_YorumID_seq"'::regclass);


--
-- TOC entry 4725 (class 2604 OID 82055)
-- Name: kişi kişi_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."kişi" ALTER COLUMN "kişi_id" SET DEFAULT nextval('public."kişi_kişi_id_seq"'::regclass);


--
-- TOC entry 4726 (class 2604 OID 82062)
-- Name: Çalışan çalışan_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Çalışan" ALTER COLUMN "çalışan_id" SET DEFAULT nextval('public."Çalışan_çalışan_id_seq"'::regclass);


--
-- TOC entry 4717 (class 2604 OID 74391)
-- Name: ÖdemeYöntemleri ÖdemeID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ÖdemeYöntemleri" ALTER COLUMN "ÖdemeID" SET DEFAULT nextval('public."ÖdemeYöntemleri_ÖdemeID_seq"'::regclass);


--
-- TOC entry 4712 (class 2604 OID 74297)
-- Name: Ürünler ÜrünID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ürünler" ALTER COLUMN "ÜrünID" SET DEFAULT nextval('public."Ürünler_ÜrünID_seq"'::regclass);


--
-- TOC entry 4718 (class 2604 OID 74403)
-- Name: İadeTalepleri İadeID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."İadeTalepleri" ALTER COLUMN "İadeID" SET DEFAULT nextval('public."İadeTalepleri_İadeID_seq"'::regclass);


--
-- TOC entry 4720 (class 2604 OID 74424)
-- Name: İndirimler İndirimID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."İndirimler" ALTER COLUMN "İndirimID" SET DEFAULT nextval('public."İndirimler_İndirimID_seq"'::regclass);


--
-- TOC entry 4723 (class 2604 OID 74469)
-- Name: İstatistikler İstatistikID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."İstatistikler" ALTER COLUMN "İstatistikID" SET DEFAULT nextval('public."İstatistikler_İstatistikID_seq"'::regclass);


--
-- TOC entry 4951 (class 0 OID 74454)
-- Dependencies: 238
-- Data for Name: Garanti; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Garanti" ("GarantiID", "ÜrünID", "BaşlangıçTarihi", "BitişTarihi", "GarantiDurumu") FROM stdin;
1	1	2023-12-15	2025-12-15	Aktif
2	2	2023-12-15	2025-12-15	Aktif
3	3	2023-12-15	2025-12-15	Aktif
4	4	2023-12-15	2025-12-15	Aktif
5	5	2023-12-15	2025-12-15	Aktif
6	6	2023-12-15	2025-12-15	Aktif
7	7	2023-12-15	2025-12-15	Aktif
9	11	2023-12-15	2025-12-15	Aktif
10	12	2023-12-15	2025-12-15	Aktif
\.


--
-- TOC entry 4929 (class 0 OID 74287)
-- Dependencies: 216
-- Data for Name: Kategoriler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Kategoriler" ("KategoriID", "KategoriAdı") FROM stdin;
6	Video Oyunu ve Konsol
5	Monitör
4	Kulaklık
3	Televizyon
2	Telefon
1	Bilgisayar
\.


--
-- TOC entry 4963 (class 0 OID 90208)
-- Dependencies: 250
-- Data for Name: Kullanici; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Kullanici" ("KullaniciID", "kullaniciAdi", "kullaniciSifre") FROM stdin;
1	emrhn	672854
\.


--
-- TOC entry 4937 (class 0 OID 74359)
-- Dependencies: 224
-- Data for Name: MüşteriAdresleri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."MüşteriAdresleri" ("AdresID", "MüşteriID", "Adres") FROM stdin;
\.


--
-- TOC entry 4961 (class 0 OID 82076)
-- Dependencies: 248
-- Data for Name: Müşteriler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Müşteriler" ("müşteri_id", telefon, "kişi_id") FROM stdin;
1	05301156728	1
2	05369148407	2
3	05301112233	3
\.


--
-- TOC entry 4945 (class 0 OID 74412)
-- Dependencies: 232
-- Data for Name: Satıcılar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Satıcılar" ("SatıcıID", "Ad", "Soyad", "MağazaAdı") FROM stdin;
\.


--
-- TOC entry 4939 (class 0 OID 74371)
-- Dependencies: 226
-- Data for Name: Satışlar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Satışlar" ("SatışID", "ÇalışanID", "SiparişID", "Tarih", "ToplamTutar") FROM stdin;
\.


--
-- TOC entry 4935 (class 0 OID 74331)
-- Dependencies: 222
-- Data for Name: SiparişDetayları; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SiparişDetayları" ("DetayID", "SiparişID", "ÜrünID", "Miktar", "BirimFiyat") FROM stdin;
1	7	1	1	24000
\.


--
-- TOC entry 4933 (class 0 OID 74317)
-- Dependencies: 220
-- Data for Name: Siparişler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Siparişler" ("SiparişID", "MüşteriID", "Tarih", "ToplamTutar", "Durum") FROM stdin;
7	1	2023-12-22	24000	Tamamlandı
\.


--
-- TOC entry 4955 (class 0 OID 74508)
-- Dependencies: 242
-- Data for Name: StokLog; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."StokLog" ("LogID", "ÜrünID", "Tarih", "Mesaj") FROM stdin;
2	5	2023-12-25 13:09:59.927669	Sony Bravia TV 4K stokları tükendi!
\.


--
-- TOC entry 4949 (class 0 OID 74435)
-- Dependencies: 236
-- Data for Name: Yorumlar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Yorumlar" ("YorumID", "ÜrünID", "MüşteriID", "YorumMetni", "Puan") FROM stdin;
\.


--
-- TOC entry 4957 (class 0 OID 82052)
-- Dependencies: 244
-- Data for Name: kişi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."kişi" ("kişi_id", ad, soyad, email) FROM stdin;
1	Emirhan	Aksu	emrhnaxu@gmail.com
2	Semih	Özçaka	semihozcaka@gmail.com
3	tahir	ozdemir	tahozdemir@mail.com
\.


--
-- TOC entry 4959 (class 0 OID 82059)
-- Dependencies: 246
-- Data for Name: Çalışan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Çalışan" ("çalışan_id", pozisyon, "kişi_id") FROM stdin;
\.


--
-- TOC entry 4941 (class 0 OID 74388)
-- Dependencies: 228
-- Data for Name: ÖdemeYöntemleri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ÖdemeYöntemleri" ("ÖdemeID", "MüşteriID", "Tür", "KartNumarası") FROM stdin;
\.


--
-- TOC entry 4931 (class 0 OID 74294)
-- Dependencies: 218
-- Data for Name: Ürünler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Ürünler" ("ÜrünID", "ÜrünAdı", "KategoriID", "Fiyat", "StokMiktarı") FROM stdin;
2	Lenovo LOQ 5	1	30000	100
3	Samsung Galaxy S20	2	20000	50
11	Monster Abra A7 V13.2.2	2	30000	100
12	Asus ROG Strix	1	35000	80
13	MSI Katana	1	36000	50
14	MSI GL65	1	72000	10
15	HP Victus	1	32000	30
6	Apple AirPods Pro	4	6500	120
4	HP Pavilion 15	1	26000	75
1	Lenovo Ideapad 5 Pro	1	25000	100
7	Dell Inspiron 5000	1	24500	90
5	Sony Bravia TV 4K	3	12500	0
\.


--
-- TOC entry 4943 (class 0 OID 74400)
-- Dependencies: 230
-- Data for Name: İadeTalepleri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."İadeTalepleri" ("İadeID", "SiparişID", "Tarih", "Durum") FROM stdin;
\.


--
-- TOC entry 4947 (class 0 OID 74421)
-- Dependencies: 234
-- Data for Name: İndirimler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."İndirimler" ("İndirimID", "ÜrünID", "İndirimOranı", "BaşlangıçTarihi", "BitişTarihi") FROM stdin;
\.


--
-- TOC entry 4953 (class 0 OID 74466)
-- Dependencies: 240
-- Data for Name: İstatistikler; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."İstatistikler" ("İstatistikID", "Tarih", "SatışAdedi", "Gelir") FROM stdin;
\.


--
-- TOC entry 4987 (class 0 OID 0)
-- Dependencies: 237
-- Name: Garanti_GarantiID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Garanti_GarantiID_seq"', 10, true);


--
-- TOC entry 4988 (class 0 OID 0)
-- Dependencies: 215
-- Name: Kategoriler_KategoriID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Kategoriler_KategoriID_seq"', 8, true);


--
-- TOC entry 4989 (class 0 OID 0)
-- Dependencies: 249
-- Name: Kullanici_KullaniciID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Kullanici_KullaniciID_seq"', 1, true);


--
-- TOC entry 4990 (class 0 OID 0)
-- Dependencies: 223
-- Name: MüşteriAdresleri_AdresID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."MüşteriAdresleri_AdresID_seq"', 1, false);


--
-- TOC entry 4991 (class 0 OID 0)
-- Dependencies: 247
-- Name: Müşteriler_müşteri_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Müşteriler_müşteri_id_seq"', 3, true);


--
-- TOC entry 4992 (class 0 OID 0)
-- Dependencies: 231
-- Name: Satıcılar_SatıcıID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Satıcılar_SatıcıID_seq"', 1, false);


--
-- TOC entry 4993 (class 0 OID 0)
-- Dependencies: 225
-- Name: Satışlar_SatışID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Satışlar_SatışID_seq"', 5, true);


--
-- TOC entry 4994 (class 0 OID 0)
-- Dependencies: 221
-- Name: SiparişDetayları_DetayID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."SiparişDetayları_DetayID_seq"', 1, true);


--
-- TOC entry 4995 (class 0 OID 0)
-- Dependencies: 219
-- Name: Siparişler_SiparişID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Siparişler_SiparişID_seq"', 7, true);


--
-- TOC entry 4996 (class 0 OID 0)
-- Dependencies: 241
-- Name: StokLog_LogID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."StokLog_LogID_seq"', 2, true);


--
-- TOC entry 4997 (class 0 OID 0)
-- Dependencies: 235
-- Name: Yorumlar_YorumID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Yorumlar_YorumID_seq"', 1, false);


--
-- TOC entry 4998 (class 0 OID 0)
-- Dependencies: 243
-- Name: kişi_kişi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."kişi_kişi_id_seq"', 3, true);


--
-- TOC entry 4999 (class 0 OID 0)
-- Dependencies: 245
-- Name: Çalışan_çalışan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Çalışan_çalışan_id_seq"', 1, false);


--
-- TOC entry 5000 (class 0 OID 0)
-- Dependencies: 227
-- Name: ÖdemeYöntemleri_ÖdemeID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ÖdemeYöntemleri_ÖdemeID_seq"', 1, false);


--
-- TOC entry 5001 (class 0 OID 0)
-- Dependencies: 217
-- Name: Ürünler_ÜrünID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Ürünler_ÜrünID_seq"', 15, true);


--
-- TOC entry 5002 (class 0 OID 0)
-- Dependencies: 229
-- Name: İadeTalepleri_İadeID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."İadeTalepleri_İadeID_seq"', 1, false);


--
-- TOC entry 5003 (class 0 OID 0)
-- Dependencies: 233
-- Name: İndirimler_İndirimID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."İndirimler_İndirimID_seq"', 1, false);


--
-- TOC entry 5004 (class 0 OID 0)
-- Dependencies: 239
-- Name: İstatistikler_İstatistikID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."İstatistikler_İstatistikID_seq"', 1, true);


--
-- TOC entry 4752 (class 2606 OID 74459)
-- Name: Garanti Garanti_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Garanti"
    ADD CONSTRAINT "Garanti_pkey" PRIMARY KEY ("GarantiID");


--
-- TOC entry 4764 (class 2606 OID 90215)
-- Name: Kullanici ID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kullanici"
    ADD CONSTRAINT "ID" PRIMARY KEY ("KullaniciID");


--
-- TOC entry 4730 (class 2606 OID 74292)
-- Name: Kategoriler Kategoriler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kategoriler"
    ADD CONSTRAINT "Kategoriler_pkey" PRIMARY KEY ("KategoriID");


--
-- TOC entry 4738 (class 2606 OID 74364)
-- Name: MüşteriAdresleri MüşteriAdresleri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MüşteriAdresleri"
    ADD CONSTRAINT "MüşteriAdresleri_pkey" PRIMARY KEY ("AdresID");


--
-- TOC entry 4762 (class 2606 OID 82081)
-- Name: Müşteriler Müşteriler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Müşteriler"
    ADD CONSTRAINT "Müşteriler_pkey" PRIMARY KEY ("müşteri_id");


--
-- TOC entry 4746 (class 2606 OID 74419)
-- Name: Satıcılar Satıcılar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Satıcılar"
    ADD CONSTRAINT "Satıcılar_pkey" PRIMARY KEY ("SatıcıID");


--
-- TOC entry 4740 (class 2606 OID 74376)
-- Name: Satışlar Satışlar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Satışlar"
    ADD CONSTRAINT "Satışlar_pkey" PRIMARY KEY ("SatışID");


--
-- TOC entry 4736 (class 2606 OID 74338)
-- Name: SiparişDetayları SiparişDetayları_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SiparişDetayları"
    ADD CONSTRAINT "SiparişDetayları_pkey" PRIMARY KEY ("DetayID");


--
-- TOC entry 4734 (class 2606 OID 74324)
-- Name: Siparişler Siparişler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Siparişler"
    ADD CONSTRAINT "Siparişler_pkey" PRIMARY KEY ("SiparişID");


--
-- TOC entry 4756 (class 2606 OID 74515)
-- Name: StokLog StokLog_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StokLog"
    ADD CONSTRAINT "StokLog_pkey" PRIMARY KEY ("LogID");


--
-- TOC entry 4750 (class 2606 OID 74442)
-- Name: Yorumlar Yorumlar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yorumlar"
    ADD CONSTRAINT "Yorumlar_pkey" PRIMARY KEY ("YorumID");


--
-- TOC entry 4758 (class 2606 OID 82057)
-- Name: kişi kişi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."kişi"
    ADD CONSTRAINT "kişi_pkey" PRIMARY KEY ("kişi_id");


--
-- TOC entry 4760 (class 2606 OID 82064)
-- Name: Çalışan Çalışan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Çalışan"
    ADD CONSTRAINT "Çalışan_pkey" PRIMARY KEY ("çalışan_id");


--
-- TOC entry 4742 (class 2606 OID 74393)
-- Name: ÖdemeYöntemleri ÖdemeYöntemleri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ÖdemeYöntemleri"
    ADD CONSTRAINT "ÖdemeYöntemleri_pkey" PRIMARY KEY ("ÖdemeID");


--
-- TOC entry 4732 (class 2606 OID 74301)
-- Name: Ürünler Ürünler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ürünler"
    ADD CONSTRAINT "Ürünler_pkey" PRIMARY KEY ("ÜrünID");


--
-- TOC entry 4744 (class 2606 OID 74405)
-- Name: İadeTalepleri İadeTalepleri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."İadeTalepleri"
    ADD CONSTRAINT "İadeTalepleri_pkey" PRIMARY KEY ("İadeID");


--
-- TOC entry 4748 (class 2606 OID 74428)
-- Name: İndirimler İndirimler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."İndirimler"
    ADD CONSTRAINT "İndirimler_pkey" PRIMARY KEY ("İndirimID");


--
-- TOC entry 4754 (class 2606 OID 74473)
-- Name: İstatistikler İstatistikler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."İstatistikler"
    ADD CONSTRAINT "İstatistikler_pkey" PRIMARY KEY ("İstatistikID");


--
-- TOC entry 4781 (class 2620 OID 74517)
-- Name: Ürünler log_stock_empty_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_stock_empty_trigger AFTER UPDATE ON public."Ürünler" FOR EACH ROW EXECUTE FUNCTION public.log_stock_empty();


--
-- TOC entry 4783 (class 2620 OID 74521)
-- Name: Satışlar trig_insert_statistics_on_sale; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trig_insert_statistics_on_sale AFTER INSERT ON public."Satışlar" FOR EACH ROW EXECUTE FUNCTION public.insert_statistics_on_sale();


--
-- TOC entry 4782 (class 2620 OID 74494)
-- Name: SiparişDetayları trig_update_order_total; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trig_update_order_total AFTER INSERT ON public."SiparişDetayları" FOR EACH ROW EXECUTE FUNCTION public.update_order_total_on_insert();


--
-- TOC entry 4784 (class 2620 OID 74500)
-- Name: İadeTalepleri trig_update_return_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trig_update_return_status AFTER INSERT ON public."İadeTalepleri" FOR EACH ROW EXECUTE FUNCTION public.update_return_status();


--
-- TOC entry 4777 (class 2606 OID 98522)
-- Name: Garanti Garanti_ÜrünID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Garanti"
    ADD CONSTRAINT "Garanti_ÜrünID_fkey" FOREIGN KEY ("ÜrünID") REFERENCES public."Ürünler"("ÜrünID") ON DELETE CASCADE;


--
-- TOC entry 4769 (class 2606 OID 82102)
-- Name: MüşteriAdresleri MüşteriAdresleri_MüşteriID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."MüşteriAdresleri"
    ADD CONSTRAINT "MüşteriAdresleri_MüşteriID_fkey" FOREIGN KEY ("MüşteriID") REFERENCES public."Müşteriler"("müşteri_id");


--
-- TOC entry 4780 (class 2606 OID 82082)
-- Name: Müşteriler Müşteriler_kişi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Müşteriler"
    ADD CONSTRAINT "Müşteriler_kişi_id_fkey" FOREIGN KEY ("kişi_id") REFERENCES public."kişi"("kişi_id");


--
-- TOC entry 4770 (class 2606 OID 74382)
-- Name: Satışlar Satışlar_SiparişID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Satışlar"
    ADD CONSTRAINT "Satışlar_SiparişID_fkey" FOREIGN KEY ("SiparişID") REFERENCES public."Siparişler"("SiparişID");


--
-- TOC entry 4771 (class 2606 OID 82070)
-- Name: Satışlar Satışlar_ÇalışanID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Satışlar"
    ADD CONSTRAINT "Satışlar_ÇalışanID_fkey" FOREIGN KEY ("ÇalışanID") REFERENCES public."Çalışan"("çalışan_id");


--
-- TOC entry 4767 (class 2606 OID 74339)
-- Name: SiparişDetayları SiparişDetayları_SiparişID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SiparişDetayları"
    ADD CONSTRAINT "SiparişDetayları_SiparişID_fkey" FOREIGN KEY ("SiparişID") REFERENCES public."Siparişler"("SiparişID");


--
-- TOC entry 4768 (class 2606 OID 74344)
-- Name: SiparişDetayları SiparişDetayları_ÜrünID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SiparişDetayları"
    ADD CONSTRAINT "SiparişDetayları_ÜrünID_fkey" FOREIGN KEY ("ÜrünID") REFERENCES public."Ürünler"("ÜrünID");


--
-- TOC entry 4766 (class 2606 OID 82097)
-- Name: Siparişler Siparişler_MüşteriID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Siparişler"
    ADD CONSTRAINT "Siparişler_MüşteriID_fkey" FOREIGN KEY ("MüşteriID") REFERENCES public."Müşteriler"("müşteri_id");


--
-- TOC entry 4775 (class 2606 OID 82092)
-- Name: Yorumlar Yorumlar_MüşteriID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yorumlar"
    ADD CONSTRAINT "Yorumlar_MüşteriID_fkey" FOREIGN KEY ("MüşteriID") REFERENCES public."Müşteriler"("müşteri_id");


--
-- TOC entry 4776 (class 2606 OID 74443)
-- Name: Yorumlar Yorumlar_ÜrünID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yorumlar"
    ADD CONSTRAINT "Yorumlar_ÜrünID_fkey" FOREIGN KEY ("ÜrünID") REFERENCES public."Ürünler"("ÜrünID");


--
-- TOC entry 4779 (class 2606 OID 82065)
-- Name: Çalışan Çalışan_kişi_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Çalışan"
    ADD CONSTRAINT "Çalışan_kişi_id_fkey" FOREIGN KEY ("kişi_id") REFERENCES public."kişi"("kişi_id");


--
-- TOC entry 4772 (class 2606 OID 82087)
-- Name: ÖdemeYöntemleri ÖdemeYöntemleri_MüşteriID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ÖdemeYöntemleri"
    ADD CONSTRAINT "ÖdemeYöntemleri_MüşteriID_fkey" FOREIGN KEY ("MüşteriID") REFERENCES public."Müşteriler"("müşteri_id");


--
-- TOC entry 4778 (class 2606 OID 82112)
-- Name: StokLog ÜrünID; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."StokLog"
    ADD CONSTRAINT "ÜrünID" FOREIGN KEY ("ÜrünID") REFERENCES public."Ürünler"("ÜrünID");


--
-- TOC entry 4765 (class 2606 OID 74302)
-- Name: Ürünler Ürünler_KategoriID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ürünler"
    ADD CONSTRAINT "Ürünler_KategoriID_fkey" FOREIGN KEY ("KategoriID") REFERENCES public."Kategoriler"("KategoriID");


--
-- TOC entry 4773 (class 2606 OID 74406)
-- Name: İadeTalepleri İadeTalepleri_SiparişID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."İadeTalepleri"
    ADD CONSTRAINT "İadeTalepleri_SiparişID_fkey" FOREIGN KEY ("SiparişID") REFERENCES public."Siparişler"("SiparişID");


--
-- TOC entry 4774 (class 2606 OID 74429)
-- Name: İndirimler İndirimler_ÜrünID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."İndirimler"
    ADD CONSTRAINT "İndirimler_ÜrünID_fkey" FOREIGN KEY ("ÜrünID") REFERENCES public."Ürünler"("ÜrünID");


-- Completed on 2023-12-25 17:14:37

--
-- PostgreSQL database dump complete
--

