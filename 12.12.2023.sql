--
-- PostgreSQL database dump
--

-- Dumped from database version 16.0
-- Dumped by pg_dump version 16.0

-- Started on 2023-12-12 02:45:53

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 65868)
-- Name: Adres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Adres" (
    "AdresID" integer NOT NULL,
    "AdresSehir" character varying(15),
    "AdresPostaKodu" numeric(5,0),
    "AdresIlce" character varying(15),
    "MusteriID" integer
);


ALTER TABLE public."Adres" OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 65889)
-- Name: AdresBina; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AdresBina" (
    "AdresID" integer NOT NULL,
    "AdresBina" character varying(15),
    "AdresKat" integer,
    "AdresDaire" integer
);


ALTER TABLE public."AdresBina" OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 65879)
-- Name: AdresIlce; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."AdresIlce" (
    "AdresID" integer NOT NULL,
    "AdresIlce" character varying(15),
    "AdresMahalle" character varying(15),
    "AdresSokak" character varying(15),
    "AdresCadde" character varying(15)
);


ALTER TABLE public."AdresIlce" OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 65867)
-- Name: Adres_AdresID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Adres_AdresID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Adres_AdresID_seq" OWNER TO postgres;

--
-- TOC entry 4921 (class 0 OID 0)
-- Dependencies: 229
-- Name: Adres_AdresID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Adres_AdresID_seq" OWNED BY public."Adres"."AdresID";


--
-- TOC entry 236 (class 1259 OID 65998)
-- Name: TedarikciID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."TedarikciID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."TedarikciID_seq" OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 57448)
-- Name: Urun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Urun" (
    "UrunID" integer NOT NULL,
    "UrunAd" character varying,
    "UrunMarka" character varying,
    "UrunModel" character varying,
    "UrunFiyat" money,
    "UrunIndirim" numeric(2,0),
    "UrunStok" integer,
    "TedarikciID" integer DEFAULT nextval('public."TedarikciID_seq"'::regclass)
);


ALTER TABLE public."Urun" OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 65631)
-- Name: Urun_UrunID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Urun_UrunID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Urun_UrunID_seq" OWNER TO postgres;

--
-- TOC entry 4922 (class 0 OID 0)
-- Dependencies: 216
-- Name: Urun_UrunID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Urun_UrunID_seq" OWNED BY public."Urun"."UrunID";


--
-- TOC entry 217 (class 1259 OID 65682)
-- Name: Bilgisayar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Bilgisayar" (
    "UrunID" integer DEFAULT nextval('public."Urun_UrunID_seq"'::regclass) NOT NULL,
    "UrunAd" character varying NOT NULL,
    "UrunMarka" character varying NOT NULL,
    "UrunModel" character varying NOT NULL,
    "UrunFiyat" money NOT NULL,
    "UrunIndirim" numeric(2,0) NOT NULL,
    "UrunStok" integer NOT NULL,
    "UrunRam" integer NOT NULL,
    "UrunDepolama" integer NOT NULL,
    "UrunIslemciMarka" character varying NOT NULL,
    "UrunIslemciModel" character varying NOT NULL,
    "UrunDepolamaTuru" character varying(4) NOT NULL,
    "UrunIsletimSistemi" character varying NOT NULL,
    "UrunEkranBoyutu" character varying NOT NULL,
    "UrunEkranKarti" character varying NOT NULL,
    "TedarikciID" integer
);


ALTER TABLE public."Bilgisayar" OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 74228)
-- Name: Depolama; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Depolama" (
    "UrunID" integer DEFAULT nextval('public."Urun_UrunID_seq"'::regclass) NOT NULL,
    "UrunAd" character varying NOT NULL,
    "UrunMarka" character varying NOT NULL,
    "UrunModel" character varying NOT NULL,
    "UrunFiyat" money NOT NULL,
    "UrunIndirim" numeric(2,0) NOT NULL,
    "UrunStok" integer NOT NULL,
    "TedarikciID" integer,
    "UrunTip" character varying,
    "UrunKapasite" integer
);


ALTER TABLE public."Depolama" OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 65708)
-- Name: EkranKarti; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."EkranKarti" (
    "UrunID" integer DEFAULT nextval('public."Urun_UrunID_seq"'::regclass) NOT NULL,
    "UrunAd" character varying NOT NULL,
    "UrunMarka" character varying NOT NULL,
    "UrunModel" character varying NOT NULL,
    "UrunFiyat" money NOT NULL,
    "UrunIndirim" numeric(2,0) NOT NULL,
    "UrunStok" integer NOT NULL,
    "TedarikciID" integer
);


ALTER TABLE public."EkranKarti" OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 65749)
-- Name: Kisi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Kisi" (
    "KisiID" integer NOT NULL,
    "KisiAd" character varying NOT NULL,
    "KisiSoyad" character varying NOT NULL,
    "KisiYas" integer NOT NULL,
    "KisiTC" numeric(11,0) NOT NULL
);


ALTER TABLE public."Kisi" OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 65748)
-- Name: Kisi_KisiID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Kisi_KisiID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Kisi_KisiID_seq" OWNER TO postgres;

--
-- TOC entry 4923 (class 0 OID 0)
-- Dependencies: 221
-- Name: Kisi_KisiID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Kisi_KisiID_seq" OWNED BY public."Kisi"."KisiID";


--
-- TOC entry 237 (class 1259 OID 66026)
-- Name: Kullanici; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Kullanici" (
    "KullaniciID" integer NOT NULL,
    "KullaniciAdi" character varying NOT NULL,
    "KullaniciSifre" character varying NOT NULL
);


ALTER TABLE public."Kullanici" OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 65735)
-- Name: Lisans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Lisans" (
    "UrunID" integer DEFAULT nextval('public."Urun_UrunID_seq"'::regclass) NOT NULL,
    "UrunAd" character varying NOT NULL,
    "UrunMarka" character varying NOT NULL,
    "UrunModel" character varying NOT NULL,
    "UrunFiyat" money NOT NULL,
    "UrunIndirim" numeric(2,0) NOT NULL,
    "UrunStok" integer NOT NULL,
    "UrunSure" timestamp without time zone NOT NULL,
    "TedarikciID" integer
);


ALTER TABLE public."Lisans" OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 65770)
-- Name: Musteri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Musteri" (
    "KisiID" integer DEFAULT nextval('public."Kisi_KisiID_seq"'::regclass) NOT NULL,
    "KisiAd" character varying NOT NULL,
    "KisiSoyad" character varying NOT NULL,
    "KisiYas" integer NOT NULL,
    "KisiTC" numeric(11,0) NOT NULL
);


ALTER TABLE public."Musteri" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 65757)
-- Name: Personel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Personel" (
    "KisiID" integer DEFAULT nextval('public."Kisi_KisiID_seq"'::regclass) NOT NULL,
    "KisiAd" character varying NOT NULL,
    "KisiSoyad" character varying NOT NULL,
    "KisiYas" integer NOT NULL,
    "KisiTC" numeric(11,0) NOT NULL,
    "PersonelGiris" timestamp without time zone NOT NULL,
    "PersonelCalisma" boolean NOT NULL,
    "PersonelDepartman" character varying NOT NULL
);


ALTER TABLE public."Personel" OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 65722)
-- Name: Ram; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Ram" (
    "UrunID" integer DEFAULT nextval('public."Urun_UrunID_seq"'::regclass) NOT NULL,
    "UrunAd" character varying NOT NULL,
    "UrunMarka" character varying NOT NULL,
    "UrunModel" character varying NOT NULL,
    "UrunFiyat" money NOT NULL,
    "UrunIndirim" numeric(2,0) NOT NULL,
    "UrunStok" integer NOT NULL,
    "UrunKapasite" integer NOT NULL,
    "TedarikciID" integer
);


ALTER TABLE public."Ram" OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 65831)
-- Name: Siparis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Siparis" (
    "SiparisID" integer NOT NULL,
    "SiparisTarihi" timestamp without time zone,
    "SiparisTutar" money,
    "SiparisDurum" boolean,
    "MusteriID" integer
);


ALTER TABLE public."Siparis" OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 65843)
-- Name: SiparisUrun; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SiparisUrun" (
    "SiparisUrunID" integer NOT NULL,
    "SiparisID" integer,
    "UrunID" integer
);


ALTER TABLE public."SiparisUrun" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 65842)
-- Name: SiparisUrun_SiparisUrunID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."SiparisUrun_SiparisUrunID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."SiparisUrun_SiparisUrunID_seq" OWNER TO postgres;

--
-- TOC entry 4924 (class 0 OID 0)
-- Dependencies: 227
-- Name: SiparisUrun_SiparisUrunID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."SiparisUrun_SiparisUrunID_seq" OWNED BY public."SiparisUrun"."SiparisUrunID";


--
-- TOC entry 225 (class 1259 OID 65830)
-- Name: Siparis_SiparisID_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Siparis_SiparisID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Siparis_SiparisID_seq" OWNER TO postgres;

--
-- TOC entry 4925 (class 0 OID 0)
-- Dependencies: 225
-- Name: Siparis_SiparisID_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Siparis_SiparisID_seq" OWNED BY public."Siparis"."SiparisID";


--
-- TOC entry 233 (class 1259 OID 65899)
-- Name: Sube; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Sube" (
    "SubeID" integer NOT NULL,
    "SubeAd" character varying(15),
    "SubeSehir" character varying(15),
    "SubeTel" numeric(11,0)
);


ALTER TABLE public."Sube" OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 65992)
-- Name: Tedarikci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Tedarikci" (
    "TedarikciID" integer NOT NULL,
    "TedarikciAd" character varying(15),
    "TedarikciTel" numeric(11,0),
    "TedarikciUlke" character varying(15)
);


ALTER TABLE public."Tedarikci" OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 65991)
-- Name: Tedarikci1_TedarikciID_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Tedarikci1_TedarikciID_seq1"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Tedarikci1_TedarikciID_seq1" OWNER TO postgres;

--
-- TOC entry 4926 (class 0 OID 0)
-- Dependencies: 234
-- Name: Tedarikci1_TedarikciID_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Tedarikci1_TedarikciID_seq1" OWNED BY public."Tedarikci"."TedarikciID";


--
-- TOC entry 4699 (class 2604 OID 65871)
-- Name: Adres AdresID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Adres" ALTER COLUMN "AdresID" SET DEFAULT nextval('public."Adres_AdresID_seq"'::regclass);


--
-- TOC entry 4694 (class 2604 OID 65752)
-- Name: Kisi KisiID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kisi" ALTER COLUMN "KisiID" SET DEFAULT nextval('public."Kisi_KisiID_seq"'::regclass);


--
-- TOC entry 4697 (class 2604 OID 65834)
-- Name: Siparis SiparisID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Siparis" ALTER COLUMN "SiparisID" SET DEFAULT nextval('public."Siparis_SiparisID_seq"'::regclass);


--
-- TOC entry 4698 (class 2604 OID 65846)
-- Name: SiparisUrun SiparisUrunID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SiparisUrun" ALTER COLUMN "SiparisUrunID" SET DEFAULT nextval('public."SiparisUrun_SiparisUrunID_seq"'::regclass);


--
-- TOC entry 4700 (class 2604 OID 65995)
-- Name: Tedarikci TedarikciID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Tedarikci" ALTER COLUMN "TedarikciID" SET DEFAULT nextval('public."Tedarikci1_TedarikciID_seq1"'::regclass);


--
-- TOC entry 4688 (class 2604 OID 65977)
-- Name: Urun UrunID; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Urun" ALTER COLUMN "UrunID" SET DEFAULT (nextval('public."Urun_UrunID_seq"'::regclass) + 100000);


--
-- TOC entry 4907 (class 0 OID 65868)
-- Dependencies: 230
-- Data for Name: Adres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Adres" ("AdresID", "AdresSehir", "AdresPostaKodu", "AdresIlce", "MusteriID") FROM stdin;
1	Sakarya	54050	Serdivan	2
\.


--
-- TOC entry 4909 (class 0 OID 65889)
-- Dependencies: 232
-- Data for Name: AdresBina; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AdresBina" ("AdresID", "AdresBina", "AdresKat", "AdresDaire") FROM stdin;
\.


--
-- TOC entry 4908 (class 0 OID 65879)
-- Dependencies: 231
-- Data for Name: AdresIlce; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."AdresIlce" ("AdresID", "AdresIlce", "AdresMahalle", "AdresSokak", "AdresCadde") FROM stdin;
\.


--
-- TOC entry 4894 (class 0 OID 65682)
-- Dependencies: 217
-- Data for Name: Bilgisayar; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Bilgisayar" ("UrunID", "UrunAd", "UrunMarka", "UrunModel", "UrunFiyat", "UrunIndirim", "UrunStok", "UrunRam", "UrunDepolama", "UrunIslemciMarka", "UrunIslemciModel", "UrunDepolamaTuru", "UrunIsletimSistemi", "UrunEkranBoyutu", "UrunEkranKarti", "TedarikciID") FROM stdin;
\.


--
-- TOC entry 4915 (class 0 OID 74228)
-- Dependencies: 238
-- Data for Name: Depolama; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Depolama" ("UrunID", "UrunAd", "UrunMarka", "UrunModel", "UrunFiyat", "UrunIndirim", "UrunStok", "TedarikciID", "UrunTip", "UrunKapasite") FROM stdin;
\.


--
-- TOC entry 4895 (class 0 OID 65708)
-- Dependencies: 218
-- Data for Name: EkranKarti; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."EkranKarti" ("UrunID", "UrunAd", "UrunMarka", "UrunModel", "UrunFiyat", "UrunIndirim", "UrunStok", "TedarikciID") FROM stdin;
\.


--
-- TOC entry 4899 (class 0 OID 65749)
-- Dependencies: 222
-- Data for Name: Kisi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Kisi" ("KisiID", "KisiAd", "KisiSoyad", "KisiYas", "KisiTC") FROM stdin;
2	Emirhan	Aksu	21	11111111111
\.


--
-- TOC entry 4914 (class 0 OID 66026)
-- Dependencies: 237
-- Data for Name: Kullanici; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Kullanici" ("KullaniciID", "KullaniciAdi", "KullaniciSifre") FROM stdin;
1	emrhn	67672828
\.


--
-- TOC entry 4897 (class 0 OID 65735)
-- Dependencies: 220
-- Data for Name: Lisans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Lisans" ("UrunID", "UrunAd", "UrunMarka", "UrunModel", "UrunFiyat", "UrunIndirim", "UrunStok", "UrunSure", "TedarikciID") FROM stdin;
\.


--
-- TOC entry 4901 (class 0 OID 65770)
-- Dependencies: 224
-- Data for Name: Musteri; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Musteri" ("KisiID", "KisiAd", "KisiSoyad", "KisiYas", "KisiTC") FROM stdin;
2	Emirhan	Aksu	21	11111111111
\.


--
-- TOC entry 4900 (class 0 OID 65757)
-- Dependencies: 223
-- Data for Name: Personel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Personel" ("KisiID", "KisiAd", "KisiSoyad", "KisiYas", "KisiTC", "PersonelGiris", "PersonelCalisma", "PersonelDepartman") FROM stdin;
\.


--
-- TOC entry 4896 (class 0 OID 65722)
-- Dependencies: 219
-- Data for Name: Ram; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Ram" ("UrunID", "UrunAd", "UrunMarka", "UrunModel", "UrunFiyat", "UrunIndirim", "UrunStok", "UrunKapasite", "TedarikciID") FROM stdin;
\.


--
-- TOC entry 4903 (class 0 OID 65831)
-- Dependencies: 226
-- Data for Name: Siparis; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Siparis" ("SiparisID", "SiparisTarihi", "SiparisTutar", "SiparisDurum", "MusteriID") FROM stdin;
\.


--
-- TOC entry 4905 (class 0 OID 65843)
-- Dependencies: 228
-- Data for Name: SiparisUrun; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SiparisUrun" ("SiparisUrunID", "SiparisID", "UrunID") FROM stdin;
\.


--
-- TOC entry 4910 (class 0 OID 65899)
-- Dependencies: 233
-- Data for Name: Sube; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Sube" ("SubeID", "SubeAd", "SubeSehir", "SubeTel") FROM stdin;
\.


--
-- TOC entry 4912 (class 0 OID 65992)
-- Dependencies: 235
-- Data for Name: Tedarikci; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Tedarikci" ("TedarikciID", "TedarikciAd", "TedarikciTel", "TedarikciUlke") FROM stdin;
1	Emirhan	5301156728	Türkiye
2	Yavuz	8201112867	Türkiye
\.


--
-- TOC entry 4892 (class 0 OID 57448)
-- Dependencies: 215
-- Data for Name: Urun; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Urun" ("UrunID", "UrunAd", "UrunMarka", "UrunModel", "UrunFiyat", "UrunIndirim", "UrunStok", "TedarikciID") FROM stdin;
\.


--
-- TOC entry 4927 (class 0 OID 0)
-- Dependencies: 229
-- Name: Adres_AdresID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Adres_AdresID_seq"', 1, true);


--
-- TOC entry 4928 (class 0 OID 0)
-- Dependencies: 221
-- Name: Kisi_KisiID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Kisi_KisiID_seq"', 2, true);


--
-- TOC entry 4929 (class 0 OID 0)
-- Dependencies: 227
-- Name: SiparisUrun_SiparisUrunID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."SiparisUrun_SiparisUrunID_seq"', 1, false);


--
-- TOC entry 4930 (class 0 OID 0)
-- Dependencies: 225
-- Name: Siparis_SiparisID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Siparis_SiparisID_seq"', 1, false);


--
-- TOC entry 4931 (class 0 OID 0)
-- Dependencies: 234
-- Name: Tedarikci1_TedarikciID_seq1; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Tedarikci1_TedarikciID_seq1"', 2, true);


--
-- TOC entry 4932 (class 0 OID 0)
-- Dependencies: 236
-- Name: TedarikciID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."TedarikciID_seq"', 1, false);


--
-- TOC entry 4933 (class 0 OID 0)
-- Dependencies: 216
-- Name: Urun_UrunID_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Urun_UrunID_seq"', 1, false);


--
-- TOC entry 4727 (class 2606 OID 65893)
-- Name: AdresBina AdresBina_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdresBina"
    ADD CONSTRAINT "AdresBina_pkey" PRIMARY KEY ("AdresID");


--
-- TOC entry 4725 (class 2606 OID 65883)
-- Name: AdresIlce AdresIlce_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdresIlce"
    ADD CONSTRAINT "AdresIlce_pkey" PRIMARY KEY ("AdresID");


--
-- TOC entry 4723 (class 2606 OID 65873)
-- Name: Adres Adres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Adres"
    ADD CONSTRAINT "Adres_pkey" PRIMARY KEY ("AdresID");


--
-- TOC entry 4705 (class 2606 OID 65689)
-- Name: Bilgisayar Bilgisayar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bilgisayar"
    ADD CONSTRAINT "Bilgisayar_pkey" PRIMARY KEY ("UrunID");


--
-- TOC entry 4735 (class 2606 OID 74235)
-- Name: Depolama Depolama_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Depolama"
    ADD CONSTRAINT "Depolama_pkey" PRIMARY KEY ("UrunID");


--
-- TOC entry 4707 (class 2606 OID 65715)
-- Name: EkranKarti EkranKarti_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EkranKarti"
    ADD CONSTRAINT "EkranKarti_pkey" PRIMARY KEY ("UrunID");


--
-- TOC entry 4713 (class 2606 OID 65756)
-- Name: Kisi Kisi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kisi"
    ADD CONSTRAINT "Kisi_pkey" PRIMARY KEY ("KisiID");


--
-- TOC entry 4733 (class 2606 OID 66032)
-- Name: Kullanici Kullanici_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kullanici"
    ADD CONSTRAINT "Kullanici_pkey" PRIMARY KEY ("KullaniciID");


--
-- TOC entry 4711 (class 2606 OID 65742)
-- Name: Lisans Lisans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lisans"
    ADD CONSTRAINT "Lisans_pkey" PRIMARY KEY ("UrunID");


--
-- TOC entry 4717 (class 2606 OID 65777)
-- Name: Musteri Musteri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Musteri"
    ADD CONSTRAINT "Musteri_pkey" PRIMARY KEY ("KisiID");


--
-- TOC entry 4715 (class 2606 OID 65764)
-- Name: Personel Personel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT "Personel_pkey" PRIMARY KEY ("KisiID");


--
-- TOC entry 4709 (class 2606 OID 65729)
-- Name: Ram RAM_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ram"
    ADD CONSTRAINT "RAM_pkey" PRIMARY KEY ("UrunID");


--
-- TOC entry 4721 (class 2606 OID 65848)
-- Name: SiparisUrun SiparisUrun_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SiparisUrun"
    ADD CONSTRAINT "SiparisUrun_pkey" PRIMARY KEY ("SiparisUrunID");


--
-- TOC entry 4719 (class 2606 OID 65836)
-- Name: Siparis Siparis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Siparis"
    ADD CONSTRAINT "Siparis_pkey" PRIMARY KEY ("SiparisID");


--
-- TOC entry 4729 (class 2606 OID 65903)
-- Name: Sube Sube_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sube"
    ADD CONSTRAINT "Sube_pkey" PRIMARY KEY ("SubeID");


--
-- TOC entry 4731 (class 2606 OID 65997)
-- Name: Tedarikci Tedarikci1_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Tedarikci"
    ADD CONSTRAINT "Tedarikci1_pkey1" PRIMARY KEY ("TedarikciID");


--
-- TOC entry 4703 (class 2606 OID 65639)
-- Name: Urun Urun_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Urun"
    ADD CONSTRAINT "Urun_pkey" PRIMARY KEY ("UrunID");


--
-- TOC entry 4747 (class 2606 OID 65894)
-- Name: AdresBina AdresBina_AdresID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdresBina"
    ADD CONSTRAINT "AdresBina_AdresID_fkey" FOREIGN KEY ("AdresID") REFERENCES public."Adres"("AdresID");


--
-- TOC entry 4746 (class 2606 OID 65884)
-- Name: AdresIlce AdresIlce_AdresID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."AdresIlce"
    ADD CONSTRAINT "AdresIlce_AdresID_fkey" FOREIGN KEY ("AdresID") REFERENCES public."Adres"("AdresID");


--
-- TOC entry 4745 (class 2606 OID 65874)
-- Name: Adres Adres_MusteriID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Adres"
    ADD CONSTRAINT "Adres_MusteriID_fkey" FOREIGN KEY ("MusteriID") REFERENCES public."Musteri"("KisiID");


--
-- TOC entry 4743 (class 2606 OID 65849)
-- Name: SiparisUrun SiparisUrun_SiparisID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SiparisUrun"
    ADD CONSTRAINT "SiparisUrun_SiparisID_fkey" FOREIGN KEY ("SiparisID") REFERENCES public."Siparis"("SiparisID");


--
-- TOC entry 4742 (class 2606 OID 65837)
-- Name: Siparis Siparis_MusteriID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Siparis"
    ADD CONSTRAINT "Siparis_MusteriID_fkey" FOREIGN KEY ("MusteriID") REFERENCES public."Musteri"("KisiID");


--
-- TOC entry 4736 (class 2606 OID 74246)
-- Name: Bilgisayar fk_bilgisayar_urun_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bilgisayar"
    ADD CONSTRAINT fk_bilgisayar_urun_id FOREIGN KEY ("UrunID") REFERENCES public."Urun"("UrunID");


--
-- TOC entry 4748 (class 2606 OID 74251)
-- Name: Depolama fk_depolama_urun_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Depolama"
    ADD CONSTRAINT fk_depolama_urun_id FOREIGN KEY ("UrunID") REFERENCES public."Urun"("UrunID");


--
-- TOC entry 4737 (class 2606 OID 74256)
-- Name: EkranKarti fk_ekrankarti_urun_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."EkranKarti"
    ADD CONSTRAINT fk_ekrankarti_urun_id FOREIGN KEY ("UrunID") REFERENCES public."Urun"("UrunID");


--
-- TOC entry 4740 (class 2606 OID 65765)
-- Name: Personel fk_kisi_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT fk_kisi_id FOREIGN KEY ("KisiID") REFERENCES public."Kisi"("KisiID");


--
-- TOC entry 4741 (class 2606 OID 65778)
-- Name: Musteri fk_kisi_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Musteri"
    ADD CONSTRAINT fk_kisi_id FOREIGN KEY ("KisiID") REFERENCES public."Kisi"("KisiID");


--
-- TOC entry 4739 (class 2606 OID 74261)
-- Name: Lisans fk_lisans_urun_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lisans"
    ADD CONSTRAINT fk_lisans_urun_id FOREIGN KEY ("UrunID") REFERENCES public."Urun"("UrunID");


--
-- TOC entry 4738 (class 2606 OID 74266)
-- Name: Ram fk_lisans_urun_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ram"
    ADD CONSTRAINT fk_lisans_urun_id FOREIGN KEY ("UrunID") REFERENCES public."Urun"("UrunID");


--
-- TOC entry 4744 (class 2606 OID 74271)
-- Name: SiparisUrun fk_siparisurun_urun_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SiparisUrun"
    ADD CONSTRAINT fk_siparisurun_urun_id FOREIGN KEY ("UrunID") REFERENCES public."Urun"("UrunID");


-- Completed on 2023-12-12 02:45:53

--
-- PostgreSQL database dump complete
--

