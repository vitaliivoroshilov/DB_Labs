--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

-- Started on 2024-06-05 14:13:14

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
-- TOC entry 253 (class 1255 OID 16818)
-- Name: add_optional_attribute_in_customers(bigint, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_optional_attribute_in_customers(IN arg_id_customer bigint, IN arg_attr_name character varying, IN arg_value character varying)
    LANGUAGE plpgsql
    AS $$DECLARE
	curs REFCURSOR;
	rec RECORD;
BEGIN
	OPEN curs FOR
		SELECT *
		FROM customers_optional_attributes;
	LOOP
		FETCH curs INTO rec;
		EXIT WHEN NOT FOUND;
		UPDATE customers_optional_attributes
			SET relevance = true, value = arg_value
			WHERE id_customer = arg_id_customer
				AND attr_name = arg_attr_name;
	END LOOP;
	CLOSE curs;
END;$$;


ALTER PROCEDURE public.add_optional_attribute_in_customers(IN arg_id_customer bigint, IN arg_attr_name character varying, IN arg_value character varying) OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 16833)
-- Name: add_optional_attribute_in_products(bigint, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.add_optional_attribute_in_products(IN arg_id_product bigint, IN arg_attr_name character varying, IN arg_value character varying)
    LANGUAGE plpgsql
    AS $$DECLARE
	curs REFCURSOR;
	rec RECORD;
BEGIN
	OPEN curs FOR
		SELECT *
		FROM products_optional_attributes;
	LOOP
		FETCH curs INTO rec;
		EXIT WHEN NOT FOUND;
		UPDATE products_optional_attributes
			SET relevance = true, value = arg_value
			WHERE id_product = arg_id_product
				AND attr_name = arg_attr_name;
	END LOOP;
	CLOSE curs;
END;
$$;


ALTER PROCEDURE public.add_optional_attribute_in_products(IN arg_id_product bigint, IN arg_attr_name character varying, IN arg_value character varying) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 16790)
-- Name: cursor_inc_demanded_products_price(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.cursor_inc_demanded_products_price()
    LANGUAGE plpgsql
    AS $$DECLARE
	curs REFCURSOR;
	rec RECORD;
BEGIN
	OPEN curs FOR
		SELECT *
		FROM orders
		WHERE quantity > (
			SELECT AVG(quantity)
			FROM orders
		);
	LOOP
		FETCH curs INTO rec;
		EXIT WHEN NOT FOUND;
		UPDATE products
			SET price = price + 5
			WHERE products.idp = rec.id_product;
	END LOOP;
	CLOSE curs;
END;$$;


ALTER PROCEDURE public.cursor_inc_demanded_products_price() OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16795)
-- Name: delete_from_customers_and_orders(bigint); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_from_customers_and_orders(IN arg_idc bigint)
    LANGUAGE plpgsql
    AS $$BEGIN
	DELETE FROM orders
	WHERE id_customer = arg_idc;
	DELETE FROM customers
	WHERE idc = arg_idc;
END;$$;


ALTER PROCEDURE public.delete_from_customers_and_orders(IN arg_idc bigint) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 16796)
-- Name: delete_from_products_and_orders(bigint); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_from_products_and_orders(IN arg_idp bigint)
    LANGUAGE plpgsql
    AS $$BEGIN
	DELETE FROM orders
	WHERE id_product = arg_idp;
	DELETE FROM products
	WHERE idp = arg_idp;
END;$$;


ALTER PROCEDURE public.delete_from_products_and_orders(IN arg_idp bigint) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16768)
-- Name: insert_in_orders(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_in_orders() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
	IF NEW.date > CURRENT_TIMESTAMP THEN
		RAISE EXCEPTION 'Incorrect date!';
	END IF;
	RETURN NEW;
END;$$;


ALTER FUNCTION public.insert_in_orders() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 235 (class 1259 OID 16803)
-- Name: customers_optional_attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers_optional_attributes (
    idoa bigint NOT NULL,
    id_customer bigint NOT NULL,
    attr_name character varying NOT NULL,
    relevance boolean NOT NULL,
    value character varying
);


ALTER TABLE public.customers_optional_attributes OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16802)
-- Name: cusomers_optional_attributes_idoa_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cusomers_optional_attributes_idoa_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cusomers_optional_attributes_idoa_seq OWNER TO postgres;

--
-- TOC entry 4903 (class 0 OID 0)
-- Dependencies: 234
-- Name: cusomers_optional_attributes_idoa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cusomers_optional_attributes_idoa_seq OWNED BY public.customers_optional_attributes.idoa;


--
-- TOC entry 216 (class 1259 OID 16460)
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    idc bigint NOT NULL,
    name character varying(50) NOT NULL,
    address character varying(50) NOT NULL,
    phone character varying(50) NOT NULL,
    contact character varying(50) NOT NULL
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16593)
-- Name: customers_3_in_address; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.customers_3_in_address AS
 SELECT idc,
    name,
    address,
    phone,
    contact
   FROM public.customers
  WHERE (((address)::text ~~ '3%'::text) OR ((address)::text ~~ '%3%'::text) OR ((address)::text ~~ '%3'::text));


ALTER VIEW public.customers_3_in_address OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16597)
-- Name: customers_3more_words_in_name; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.customers_3more_words_in_name AS
 SELECT idc,
    name,
    address,
    phone,
    contact
   FROM public.customers
  WHERE ((name)::text ~~ '% % %'::text);


ALTER VIEW public.customers_3more_words_in_name OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16459)
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO postgres;

--
-- TOC entry 4904 (class 0 OID 0)
-- Dependencies: 215
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.idc;


--
-- TOC entry 220 (class 1259 OID 16524)
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    ido bigint NOT NULL,
    id_customer bigint NOT NULL,
    id_product bigint NOT NULL,
    quantity bigint NOT NULL,
    date date NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16561)
-- Name: customers_join_orders; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.customers_join_orders AS
 SELECT customers.idc,
    customers.name,
    customers.address,
    customers.phone,
    customers.contact,
    orders.ido,
    orders.id_customer,
    orders.id_product,
    orders.quantity,
    orders.date
   FROM (public.customers
     JOIN public.orders ON ((customers.idc = orders.id_customer)))
  ORDER BY customers.idc, orders.ido;


ALTER VIEW public.customers_join_orders OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16565)
-- Name: customers_leftjoin_orders; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.customers_leftjoin_orders AS
 SELECT customers.idc,
    customers.name,
    customers.address,
    customers.phone,
    customers.contact,
    orders.ido,
    orders.id_customer,
    orders.id_product,
    orders.quantity,
    orders.date
   FROM (public.customers
     LEFT JOIN public.orders ON ((customers.idc = orders.id_customer)))
  ORDER BY customers.idc, orders.ido;


ALTER VIEW public.customers_leftjoin_orders OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16577)
-- Name: customers_leftjoin_total_quantity; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.customers_leftjoin_total_quantity AS
SELECT
    NULL::bigint AS idc,
    NULL::character varying(50) AS name,
    NULL::character varying(50) AS address,
    NULL::character varying(50) AS phone,
    NULL::character varying(50) AS contact,
    NULL::numeric AS sum;


ALTER VIEW public.customers_leftjoin_total_quantity OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16601)
-- Name: customers_with_no_orders; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.customers_with_no_orders AS
 SELECT idc,
    name,
    address,
    phone,
    contact
   FROM public.customers
  WHERE (NOT (EXISTS ( SELECT orders.ido,
            orders.id_customer,
            orders.id_product,
            orders.quantity,
            orders.date
           FROM public.orders
          WHERE (customers.idc = orders.id_customer))));


ALTER VIEW public.customers_with_no_orders OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16589)
-- Name: orders_february; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.orders_february AS
 SELECT ido,
    id_customer,
    id_product,
    quantity,
    date
   FROM public.orders
  WHERE ((date >= '2024-02-01'::date) AND (date <= '2024-02-29'::date))
  ORDER BY date;


ALTER VIEW public.orders_february OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16523)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- TOC entry 4905 (class 0 OID 0)
-- Dependencies: 219
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.ido;


--
-- TOC entry 218 (class 1259 OID 16512)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    idp bigint NOT NULL,
    price numeric(5,2) NOT NULL,
    shipping boolean NOT NULL,
    description character varying(50) NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16569)
-- Name: orders_join_products; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.orders_join_products AS
 SELECT orders.ido,
    orders.id_customer,
    orders.id_product,
    orders.quantity,
    orders.date,
    products.idp,
    products.price,
    products.shipping,
    products.description
   FROM (public.orders
     JOIN public.products ON ((orders.id_product = products.idp)))
  ORDER BY orders.date;


ALTER VIEW public.orders_join_products OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16573)
-- Name: orders_leftjoin_price_mult; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.orders_leftjoin_price_mult AS
 SELECT orders.ido,
    orders.id_customer,
    orders.id_product,
    orders.quantity,
    orders.date,
    products.price,
    ((orders.quantity)::numeric * products.price) AS sum
   FROM (public.orders
     LEFT JOIN public.products ON ((products.idp = orders.id_product)))
  ORDER BY orders.ido;


ALTER VIEW public.orders_leftjoin_price_mult OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16552)
-- Name: orders_sorted_by_date; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.orders_sorted_by_date AS
 SELECT ido AS id,
    id_customer,
    id_product,
    quantity,
    date
   FROM public.orders
  ORDER BY date;


ALTER VIEW public.orders_sorted_by_date OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16585)
-- Name: orders_time_passed; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.orders_time_passed AS
 SELECT ido,
    id_customer,
    id_product,
    quantity,
    date,
    (now() - (date)::timestamp with time zone) AS time_passed
   FROM public.orders
  ORDER BY date;


ALTER VIEW public.orders_time_passed OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16636)
-- Name: orders_where_shipping_true; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.orders_where_shipping_true AS
 SELECT ido,
    id_customer,
    id_product,
    quantity,
    date
   FROM public.orders
  WHERE (( SELECT products.shipping
           FROM public.products
          WHERE (orders.id_product = products.idp)) = true)
  ORDER BY id_product;


ALTER VIEW public.orders_where_shipping_true OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16511)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO postgres;

--
-- TOC entry 4906 (class 0 OID 0)
-- Dependencies: 217
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.idp;


--
-- TOC entry 237 (class 1259 OID 16820)
-- Name: products_optional_attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products_optional_attributes (
    idpoa bigint NOT NULL,
    id_product bigint NOT NULL,
    attr_name character varying NOT NULL,
    relevance boolean NOT NULL,
    value character varying
);


ALTER TABLE public.products_optional_attributes OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16819)
-- Name: products_optional_attributes_idpoa_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_optional_attributes_idpoa_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_optional_attributes_idpoa_seq OWNER TO postgres;

--
-- TOC entry 4907 (class 0 OID 0)
-- Dependencies: 236
-- Name: products_optional_attributes_idpoa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_optional_attributes_idpoa_seq OWNED BY public.products_optional_attributes.idpoa;


--
-- TOC entry 227 (class 1259 OID 16581)
-- Name: products_price_morethan_avgprice; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.products_price_morethan_avgprice AS
SELECT
    NULL::bigint AS idp,
    NULL::numeric(5,2) AS price,
    NULL::boolean AS shipping,
    NULL::character varying(50) AS description,
    NULL::numeric AS avg;


ALTER VIEW public.products_price_morethan_avgprice OWNER TO postgres;

--
-- TOC entry 4712 (class 2604 OID 16463)
-- Name: customers idc; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN idc SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- TOC entry 4715 (class 2604 OID 16806)
-- Name: customers_optional_attributes idoa; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers_optional_attributes ALTER COLUMN idoa SET DEFAULT nextval('public.cusomers_optional_attributes_idoa_seq'::regclass);


--
-- TOC entry 4714 (class 2604 OID 16527)
-- Name: orders ido; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN ido SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 4713 (class 2604 OID 16515)
-- Name: products idp; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN idp SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- TOC entry 4716 (class 2604 OID 16823)
-- Name: products_optional_attributes idpoa; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products_optional_attributes ALTER COLUMN idpoa SET DEFAULT nextval('public.products_optional_attributes_idpoa_seq'::regclass);


--
-- TOC entry 4889 (class 0 OID 16460)
-- Dependencies: 216
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (idc, name, address, phone, contact) FROM stdin;
1	Crooks, Weber and Turner	0869 Lyons Place	+86 (104) 145-8483	Kerwinn Sicily
2	Herzog, Larson and Harvey	11219 Armistice Junction	+86 (223) 708-3599	Lucien Stirrup
3	Rodriguez, Heaney and Jones	145 Sundown Parkway	+45 (423) 770-2320	Gaylene Quinnelly
4	Reilly, Leuschke and Jacobson	84730 Shopko Park	+66 (300) 227-9202	Almire Cotgrove
5	Lubowitz and Sons	79 International Parkway	+62 (184) 823-9682	Hirsch Strickett
6	Bergnaum, Pacocha and Mayert	76 North Center	+82 (128) 882-9803	Ardyth Abela
7	Daugherty, McClure and Walsh	3 Orin Lane	+54 (549) 136-2831	Livvy Killock
8	Bode-Medhurst	7902 Gateway Street	+81 (619) 367-4752	Othello Lemerle
9	Dare and Sons	23 Kennedy Trail	+81 (208) 599-7933	Lynne Vernau
10	Crist LLC	9298 Artisan Drive	+86 (525) 857-3012	Beatrix Culcheth
\.


--
-- TOC entry 4895 (class 0 OID 16803)
-- Dependencies: 235
-- Data for Name: customers_optional_attributes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers_optional_attributes (idoa, id_customer, attr_name, relevance, value) FROM stdin;
6	2	director	f	\N
7	2	subdirector	f	\N
8	2	country	f	\N
9	2	city	f	\N
10	3	director	f	\N
11	3	subdirector	f	\N
12	3	country	f	\N
13	3	city	f	\N
14	4	director	f	\N
15	4	subdirector	f	\N
16	4	country	f	\N
17	4	city	f	\N
18	5	director	f	\N
19	5	subdirector	f	\N
20	5	country	f	\N
21	5	city	f	\N
22	6	director	f	\N
23	6	subdirector	f	\N
24	6	country	f	\N
25	6	city	f	\N
26	7	director	f	\N
27	7	subdirector	f	\N
28	7	country	f	\N
29	7	city	f	\N
30	8	director	f	\N
31	8	subdirector	f	\N
32	8	country	f	\N
33	8	city	f	\N
34	9	director	f	\N
35	9	subdirector	f	\N
36	9	country	f	\N
37	9	city	f	\N
38	10	director	f	\N
39	10	subdirector	f	\N
40	10	country	f	\N
41	10	city	f	\N
1	1	director	f	\N
2	1	subdirector	f	\N
3	1	country	f	\N
4	1	city	f	\N
\.


--
-- TOC entry 4893 (class 0 OID 16524)
-- Dependencies: 220
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (ido, id_customer, id_product, quantity, date) FROM stdin;
1	7	2	73	2024-04-27
2	3	15	15	2024-04-26
3	2	9	16	2024-03-02
4	3	19	14	2024-04-28
5	8	22	44	2024-02-28
6	8	15	77	2024-05-01
7	7	12	95	2024-04-19
8	9	20	73	2024-01-25
9	5	11	93	2024-02-02
10	1	2	29	2024-02-01
11	2	24	12	2024-03-14
12	7	10	24	2024-04-12
13	5	11	27	2024-04-11
14	3	16	60	2024-05-29
15	10	25	30	2024-01-09
16	5	8	36	2024-01-22
17	10	16	28	2024-04-12
18	7	10	87	2024-03-06
19	7	8	29	2024-03-09
20	7	3	84	2024-01-19
21	6	25	17	2024-05-01
22	2	23	68	2024-05-05
23	2	17	99	2024-03-08
25	8	21	1	2024-01-02
26	7	14	30	2024-01-23
27	6	6	24	2024-03-22
28	6	19	100	2024-02-01
29	9	11	82	2024-03-19
30	2	16	15	2024-02-09
31	3	18	89	2024-05-01
32	5	2	99	2024-01-10
33	6	13	77	2024-05-10
34	5	19	86	2024-03-28
35	1	17	70	2024-05-13
36	9	11	36	2024-01-23
37	3	6	72	2024-05-07
38	7	3	19	2024-03-06
39	10	23	27	2024-01-04
40	3	9	17	2024-01-17
41	7	15	66	2024-01-01
42	2	22	1	2024-04-24
43	5	3	30	2024-02-22
44	5	23	95	2024-03-14
45	7	25	17	2024-04-30
46	8	13	57	2024-03-09
47	1	5	26	2024-02-04
48	5	12	6	2024-03-11
50	10	11	91	2024-02-09
24	1	25	89	2024-02-09
49	10	12	95	2024-03-22
\.


--
-- TOC entry 4891 (class 0 OID 16512)
-- Dependencies: 218
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (idp, price, shipping, description) FROM stdin;
1	67.58	t	Parsnip
4	29.42	t	Ice Cream Bar - Hagen Daz
5	7.79	t	Sea Bass - Fillets
7	75.43	t	Chinese Foods - Thick Noodles
8	9.16	f	Irish Cream - Baileys
9	53.59	t	Bread Foccacia Whole
14	6.03	f	Lemonade - Black Cherry, 591 Ml
21	12.59	f	Fenngreek Seed
22	96.43	f	Tomatoes - Orange
24	69.07	f	Vodka - Moskovskaya
20	19.94	t	Pimento - Canned
16	89.30	t	Beans - Fine
10	79.37	t	Sauce - Demi Glace
3	30.78	t	Soup - Clam Chowder, Dry Mix
18	40.78	f	Puree - Mocha
2	48.46	f	Wine - Winzer Krems Gruner
19	94.99	f	Tuna - Bluefin
17	35.26	t	Food Colouring - Orange
6	98.78	f	Ice Cream Bar - Drumstick
15	30.65	f	Stock - Beef, Brown
23	69.67	t	Straws - Cocktale
13	62.72	f	Muffin Batt - Choc Chk
11	107.60	t	Flour - Cake
25	101.80	t	Salmon - Fillets
12	26.34	f	Ginger - Fresh
\.


--
-- TOC entry 4897 (class 0 OID 16820)
-- Dependencies: 237
-- Data for Name: products_optional_attributes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products_optional_attributes (idpoa, id_product, attr_name, relevance, value) FROM stdin;
2	1	weight	f	\N
3	1	size	f	\N
4	2	expiration	f	\N
5	2	weight	f	\N
6	2	size	f	\N
7	3	expiration	f	\N
8	3	weight	f	\N
9	3	size	f	\N
10	4	expiration	f	\N
11	4	weight	f	\N
12	4	size	f	\N
13	5	expiration	f	\N
14	5	weight	f	\N
15	5	size	f	\N
16	6	expiration	f	\N
17	6	weight	f	\N
18	6	size	f	\N
19	7	expiration	f	\N
20	7	weight	f	\N
21	7	size	f	\N
22	8	expiration	f	\N
23	8	weight	f	\N
24	8	size	f	\N
25	9	expiration	f	\N
26	9	weight	f	\N
27	9	size	f	\N
28	10	expiration	f	\N
29	10	weight	f	\N
30	10	size	f	\N
31	11	expiration	f	\N
32	11	weight	f	\N
33	11	size	f	\N
34	12	expiration	f	\N
35	12	weight	f	\N
36	12	size	f	\N
37	13	expiration	f	\N
38	13	weight	f	\N
39	13	size	f	\N
40	14	expiration	f	\N
41	14	weight	f	\N
42	14	size	f	\N
43	15	expiration	f	\N
44	15	weight	f	\N
45	15	size	f	\N
46	16	expiration	f	\N
47	16	weight	f	\N
48	16	size	f	\N
49	17	expiration	f	\N
50	17	weight	f	\N
51	17	size	f	\N
52	18	expiration	f	\N
53	18	weight	f	\N
54	18	size	f	\N
55	19	expiration	f	\N
56	19	weight	f	\N
57	19	size	f	\N
58	20	expiration	f	\N
59	20	weight	f	\N
60	20	size	f	\N
61	21	expiration	f	\N
62	21	weight	f	\N
63	21	size	f	\N
64	22	expiration	f	\N
65	22	weight	f	\N
66	22	size	f	\N
67	23	expiration	f	\N
68	23	weight	f	\N
69	23	size	f	\N
70	24	expiration	f	\N
71	24	weight	f	\N
72	24	size	f	\N
73	25	expiration	f	\N
74	25	weight	f	\N
75	25	size	f	\N
1	1	expiration	f	\N
\.


--
-- TOC entry 4908 (class 0 OID 0)
-- Dependencies: 234
-- Name: cusomers_optional_attributes_idoa_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cusomers_optional_attributes_idoa_seq', 41, true);


--
-- TOC entry 4909 (class 0 OID 0)
-- Dependencies: 215
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 12, true);


--
-- TOC entry 4910 (class 0 OID 0)
-- Dependencies: 219
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 66, true);


--
-- TOC entry 4911 (class 0 OID 0)
-- Dependencies: 217
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 26, true);


--
-- TOC entry 4912 (class 0 OID 0)
-- Dependencies: 236
-- Name: products_optional_attributes_idpoa_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_optional_attributes_idpoa_seq', 75, true);


--
-- TOC entry 4724 (class 2606 OID 16810)
-- Name: customers_optional_attributes cusomers_optional_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers_optional_attributes
    ADD CONSTRAINT cusomers_optional_attributes_pkey PRIMARY KEY (idoa);


--
-- TOC entry 4718 (class 2606 OID 16465)
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (idc);


--
-- TOC entry 4722 (class 2606 OID 16529)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (ido);


--
-- TOC entry 4726 (class 2606 OID 16827)
-- Name: products_optional_attributes products_optional_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products_optional_attributes
    ADD CONSTRAINT products_optional_attributes_pkey PRIMARY KEY (idpoa);


--
-- TOC entry 4720 (class 2606 OID 16517)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (idp);


--
-- TOC entry 4880 (class 2618 OID 16580)
-- Name: customers_leftjoin_total_quantity _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.customers_leftjoin_total_quantity AS
 SELECT customers.idc,
    customers.name,
    customers.address,
    customers.phone,
    customers.contact,
    sum(orders.quantity) AS sum
   FROM (public.customers
     LEFT JOIN public.orders ON ((customers.idc = orders.id_customer)))
  GROUP BY customers.idc
  ORDER BY customers.idc;


--
-- TOC entry 4881 (class 2618 OID 16584)
-- Name: products_price_morethan_avgprice _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.products_price_morethan_avgprice AS
 SELECT idp,
    price,
    shipping,
    description,
    ( SELECT avg(products_1.price) AS avg
           FROM public.products products_1) AS avg
   FROM public.products
  WHERE (price > ( SELECT avg(products_1.price) AS avg
           FROM public.products products_1))
  GROUP BY idp
  ORDER BY price;


--
-- TOC entry 4731 (class 2620 OID 16769)
-- Name: orders insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER insert BEFORE INSERT ON public.orders FOR EACH ROW EXECUTE FUNCTION public.insert_in_orders();


--
-- TOC entry 4729 (class 2606 OID 16811)
-- Name: customers_optional_attributes cusomers_optional_attributes_id_customer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers_optional_attributes
    ADD CONSTRAINT cusomers_optional_attributes_id_customer_fkey FOREIGN KEY (id_customer) REFERENCES public.customers(idc) NOT VALID;


--
-- TOC entry 4727 (class 2606 OID 16530)
-- Name: orders orders_id_customer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_id_customer_fkey FOREIGN KEY (id_customer) REFERENCES public.customers(idc) NOT VALID;


--
-- TOC entry 4728 (class 2606 OID 16535)
-- Name: orders orders_id_product_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_id_product_fkey FOREIGN KEY (id_product) REFERENCES public.products(idp) NOT VALID;


--
-- TOC entry 4730 (class 2606 OID 16828)
-- Name: products_optional_attributes products_optional_attributes_id_product_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products_optional_attributes
    ADD CONSTRAINT products_optional_attributes_id_product_fkey FOREIGN KEY (id_product) REFERENCES public.products(idp);


-- Completed on 2024-06-05 14:13:14

--
-- PostgreSQL database dump complete
--

