--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

-- Started on 2024-06-10 11:16:01

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
-- TOC entry 236 (class 1255 OID 17139)
-- Name: find_20_5_20(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.find_20_5_20()
    LANGUAGE plpgsql
    AS $$DECLARE
	curs_sub REFCURSOR;
	curs_call REFCURSOR;
	rec_sub RECORD;
	rec_call RECORD;
	rec_call1 RECORD;
	rec_call2 RECORD;
	rec_call3 RECORD;
	dur1 BIGINT;
	dur2 BIGINT;
	dur3 BIGINT;
BEGIN
	OPEN curs_sub FOR
		SELECT *
		FROM subscribers;
	LOOP
		FETCH curs_sub INTO rec_sub;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE 'sub % ', rec_sub.ids;
		dur1 := -1;
		dur2 := -1;
		dur3 := -1;
		rec_call1 := NULL;
		rec_call2 := NULL;
		rec_call3 := NULL;
		OPEN curs_call FOR
			SELECT *
			FROM calls;
		LOOP
			FETCH curs_call INTO rec_call;
			EXIT WHEN NOT FOUND;
			IF rec_call.idsub = rec_sub.ids THEN
				IF dur1 > -1 AND dur2 > -1 AND dur3 = -1 THEN
					dur3 := rec_call.dur;
					rec_call3 := rec_call;	
					RAISE NOTICE 'calls %, %, %', rec_call1.idc, rec_call2.idc, rec_call3.idc;
				END IF;
				IF dur1 > -1 AND dur2 = -1 AND dur3 = -1 THEN
					dur2 := rec_call.dur;
					rec_call2 := rec_call;	
				END IF;
				IF dur1 = -1 AND dur2 = -1 AND dur3 = -1 THEN
					dur1 := rec_call.dur;
					rec_call1 := rec_call;
				END IF;
				IF dur1 > -1 AND dur2 > -1 AND dur3 > -1 THEN
					IF dur1 >= 20 AND dur2 < 5 AND dur3 >= 20 THEN
						INSERT INTO twenty_five_twenty (idcall) VALUES (rec_call2.idc);						
					END IF;
					dur1 := dur2;
					rec_call1 := rec_call2;
					dur2 := dur3;
					rec_call2 := rec_call3;
					dur3 := -1;
					rec_call3 := NULL;
				END IF;
			END IF;
		END LOOP;
		CLOSE curs_call;
	END LOOP;
	CLOSE curs_sub;
END;$$;


ALTER PROCEDURE public.find_20_5_20() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 17152)
-- Name: subscribers_sum_fees(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.subscribers_sum_fees()
    LANGUAGE plpgsql
    AS $$DECLARE
	curs_sub REFCURSOR;
	curs_call REFCURSOR;
	curs_tar REFCURSOR;
	rec_sub RECORD;
	rec_call RECORD;
	rec_tar RECORD;
	dur_sum BIGINT;
	monthmins BIGINT;
	monthfee BIGINT;
	minutefee BIGINT;
	fee BIGINT;
	excess BIGINT;
	excfee BIGINT;
BEGIN
	CREATE TABLE sum_fees (
			idsub BIGINT PRIMARY KEY,
			fee NUMERIC(5, 2)
	);
	OPEN curs_sub FOR
		SELECT *
		FROM subscribers;
	LOOP
		FETCH curs_sub INTO rec_sub;
		EXIT WHEN NOT FOUND;
		dur_sum := 0;
		RAISE NOTICE 'sub % ', rec_sub.ids;
		OPEN curs_call FOR
			SELECT *
			FROM calls;
		LOOP
			FETCH curs_call INTO rec_call;
			EXIT WHEN NOT FOUND;
			IF rec_call.idsub = rec_sub.ids THEN
				dur_sum := dur_sum + rec_call.dur;
			END IF;
		END LOOP;
		CLOSE curs_call;
		RAISE NOTICE 'dur_sum % ', dur_sum;
		OPEN curs_tar FOR
			SELECT *
			FROM tariffs;
		LOOP
			FETCH curs_tar INTO rec_tar;
			EXIT WHEN NOT FOUND;
			IF rec_tar.idt = rec_sub.idtar THEN
				monthmins = rec_tar.monthmins;
				monthfee := rec_tar.monthfee;
				minutefee := rec_tar.minutefee;
				fee := monthfee;
				IF dur_sum >= monthmins THEN
					fee := fee + (dur_sum - monthmins) * minutefee;
				END IF;
			END IF;
		END LOOP;
		CLOSE curs_tar;
		INSERT INTO sum_fees (idsub, fee) VALUES (rec_sub.ids, fee);
	END LOOP;
	CLOSE curs_sub;
END;$$;


ALTER PROCEDURE public.subscribers_sum_fees() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 17105)
-- Name: calls; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calls (
    idc bigint NOT NULL,
    idsub bigint NOT NULL,
    date date NOT NULL,
    dur bigint NOT NULL
);


ALTER TABLE public.calls OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 17093)
-- Name: subscribers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscribers (
    ids bigint NOT NULL,
    fn character varying NOT NULL,
    ln character varying NOT NULL,
    idtar bigint NOT NULL
);


ALTER TABLE public.subscribers OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 17115)
-- Name: billing; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.billing AS
 SELECT ids,
    fn,
    ln,
    idtar,
    COALESCE(( SELECT sum(calls.dur) AS sum
           FROM public.calls
          WHERE (calls.idsub = subscribers.ids)), ((0)::bigint)::numeric) AS calling
   FROM public.subscribers;


ALTER VIEW public.billing OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17119)
-- Name: subs_avg_dur; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.subs_avg_dur AS
SELECT
    NULL::bigint AS ids,
    NULL::character varying AS fn,
    NULL::character varying AS ln,
    NULL::bigint AS idtar,
    NULL::numeric AS avg;


ALTER VIEW public.subs_avg_dur OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17168)
-- Name: sum_fees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sum_fees (
    idsub bigint NOT NULL,
    fee numeric(5,2)
);


ALTER TABLE public.sum_fees OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 17079)
-- Name: tariffs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tariffs (
    idt bigint NOT NULL,
    name character varying NOT NULL,
    monthfee numeric(5,2) NOT NULL,
    monthmins numeric(5,2) NOT NULL,
    minutefee numeric(5,2) NOT NULL
);


ALTER TABLE public.tariffs OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17128)
-- Name: tariffs_dur_percentage; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.tariffs_dur_percentage AS
SELECT
    NULL::bigint AS idt,
    NULL::character varying AS name,
    NULL::numeric(5,2) AS monthfee,
    NULL::numeric(5,2) AS monthmins,
    NULL::numeric(5,2) AS minutefee,
    NULL::numeric AS "%";


ALTER VIEW public.tariffs_dur_percentage OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17123)
-- Name: tariffs_sum_avg_count; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.tariffs_sum_avg_count AS
SELECT
    NULL::bigint AS idt,
    NULL::character varying AS name,
    NULL::numeric(5,2) AS monthfee,
    NULL::numeric(5,2) AS monthmins,
    NULL::numeric(5,2) AS minutefee,
    NULL::numeric AS sum,
    NULL::bigint AS count,
    NULL::numeric AS avg;


ALTER VIEW public.tariffs_sum_avg_count OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17142)
-- Name: twenty_five_twenty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.twenty_five_twenty (
    idcall bigint NOT NULL
);


ALTER TABLE public.twenty_five_twenty OWNER TO postgres;

--
-- TOC entry 4829 (class 0 OID 17105)
-- Dependencies: 217
-- Data for Name: calls; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.calls VALUES (699777001, 1001, '2018-01-01', 20);
INSERT INTO public.calls VALUES (699777002, 1004, '2018-01-02', 20);
INSERT INTO public.calls VALUES (699777003, 1001, '2018-01-02', 30);
INSERT INTO public.calls VALUES (699777004, 1001, '2018-01-03', 2);
INSERT INTO public.calls VALUES (699777005, 1003, '2018-01-03', 10);
INSERT INTO public.calls VALUES (699777006, 1001, '2018-01-04', 5);
INSERT INTO public.calls VALUES (699777007, 1003, '2018-01-04', 11);
INSERT INTO public.calls VALUES (699777008, 1003, '2018-01-05', 15);
INSERT INTO public.calls VALUES (699777009, 1006, '2018-01-05', 10);
INSERT INTO public.calls VALUES (699777010, 1006, '2018-01-06', 10);
INSERT INTO public.calls VALUES (699777011, 1002, '2018-01-07', 10);
INSERT INTO public.calls VALUES (699777012, 1000, '2018-01-08', 10);
INSERT INTO public.calls VALUES (699777013, 1005, '2018-01-08', 3);
INSERT INTO public.calls VALUES (699777014, 1000, '2018-01-08', 20);
INSERT INTO public.calls VALUES (699777015, 1000, '2018-01-08', 1);
INSERT INTO public.calls VALUES (699777016, 1000, '2018-01-09', 40);
INSERT INTO public.calls VALUES (699777017, 1000, '2018-01-10', 50);
INSERT INTO public.calls VALUES (699777018, 1007, '2019-07-15', 21);


--
-- TOC entry 4828 (class 0 OID 17093)
-- Dependencies: 216
-- Data for Name: subscribers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.subscribers VALUES (1000, 'Bruce', 'Willis', 1);
INSERT INTO public.subscribers VALUES (1001, 'Gary', 'Oldman', 1);
INSERT INTO public.subscribers VALUES (1002, 'Ian', 'Holm', 2);
INSERT INTO public.subscribers VALUES (1003, 'Milla', 'Jovovich', 2);
INSERT INTO public.subscribers VALUES (1004, 'Chris', 'Tucker', 2);
INSERT INTO public.subscribers VALUES (1005, 'Luke', 'Perry', 3);
INSERT INTO public.subscribers VALUES (1006, 'Brion', 'James', 3);
INSERT INTO public.subscribers VALUES (1007, 'Lee', 'Evans', 3);


--
-- TOC entry 4831 (class 0 OID 17168)
-- Dependencies: 223
-- Data for Name: sum_fees; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.sum_fees VALUES (1000, 400.00);
INSERT INTO public.sum_fees VALUES (1001, 400.00);
INSERT INTO public.sum_fees VALUES (1002, 200.00);
INSERT INTO public.sum_fees VALUES (1003, 200.00);
INSERT INTO public.sum_fees VALUES (1004, 200.00);
INSERT INTO public.sum_fees VALUES (1005, 15.00);
INSERT INTO public.sum_fees VALUES (1006, 100.00);
INSERT INTO public.sum_fees VALUES (1007, 105.00);


--
-- TOC entry 4827 (class 0 OID 17079)
-- Dependencies: 215
-- Data for Name: tariffs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tariffs VALUES (1, 'Max', 400.00, 300.00, 1.00);
INSERT INTO public.tariffs VALUES (2, 'Average', 200.00, 150.00, 3.00);
INSERT INTO public.tariffs VALUES (3, 'Mini', 0.00, 0.00, 5.00);


--
-- TOC entry 4830 (class 0 OID 17142)
-- Dependencies: 222
-- Data for Name: twenty_five_twenty; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.twenty_five_twenty VALUES (699777015);


--
-- TOC entry 4672 (class 2606 OID 17109)
-- Name: calls calls_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calls
    ADD CONSTRAINT calls_pkey PRIMARY KEY (idc);


--
-- TOC entry 4670 (class 2606 OID 17099)
-- Name: subscribers subscribers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT subscribers_pkey PRIMARY KEY (ids);


--
-- TOC entry 4676 (class 2606 OID 17172)
-- Name: sum_fees sum_fees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sum_fees
    ADD CONSTRAINT sum_fees_pkey PRIMARY KEY (idsub);


--
-- TOC entry 4668 (class 2606 OID 17085)
-- Name: tariffs tariffs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariffs
    ADD CONSTRAINT tariffs_pkey PRIMARY KEY (idt);


--
-- TOC entry 4674 (class 2606 OID 17146)
-- Name: twenty_five_twenty twenty_five_twenty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.twenty_five_twenty
    ADD CONSTRAINT twenty_five_twenty_pkey PRIMARY KEY (idcall);


--
-- TOC entry 4824 (class 2618 OID 17122)
-- Name: subs_avg_dur _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.subs_avg_dur AS
 SELECT subscribers.ids,
    subscribers.fn,
    subscribers.ln,
    subscribers.idtar,
    avg(calls.dur) AS avg
   FROM (public.subscribers
     LEFT JOIN public.calls ON ((subscribers.ids = calls.idsub)))
  GROUP BY subscribers.ids;


--
-- TOC entry 4825 (class 2618 OID 17126)
-- Name: tariffs_sum_avg_count _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.tariffs_sum_avg_count AS
 SELECT tariffs.idt,
    tariffs.name,
    tariffs.monthfee,
    tariffs.monthmins,
    tariffs.minutefee,
    sum(calls.dur) AS sum,
    count(calls.*) AS count,
    avg(calls.dur) AS avg
   FROM ((public.tariffs
     LEFT JOIN public.subscribers ON ((subscribers.idtar = tariffs.idt)))
     LEFT JOIN public.calls ON ((subscribers.ids = calls.idsub)))
  GROUP BY tariffs.idt;


--
-- TOC entry 4826 (class 2618 OID 17131)
-- Name: tariffs_dur_percentage _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.tariffs_dur_percentage AS
 SELECT tariffs.idt,
    tariffs.name,
    tariffs.monthfee,
    tariffs.monthmins,
    tariffs.minutefee,
    (sum(calls.dur) / ( SELECT sum(calls_1.dur) AS sum
           FROM public.calls calls_1)) AS "%"
   FROM ((public.tariffs
     LEFT JOIN public.subscribers ON ((subscribers.idtar = tariffs.idt)))
     LEFT JOIN public.calls ON ((subscribers.ids = calls.idsub)))
  GROUP BY tariffs.idt;


--
-- TOC entry 4678 (class 2606 OID 17110)
-- Name: calls calls_idsub_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calls
    ADD CONSTRAINT calls_idsub_fkey FOREIGN KEY (idsub) REFERENCES public.subscribers(ids);


--
-- TOC entry 4677 (class 2606 OID 17100)
-- Name: subscribers subscribers_idtar_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscribers
    ADD CONSTRAINT subscribers_idtar_fkey FOREIGN KEY (idtar) REFERENCES public.tariffs(idt);


--
-- TOC entry 4679 (class 2606 OID 17147)
-- Name: twenty_five_twenty twenty_five_twenty_idcall_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.twenty_five_twenty
    ADD CONSTRAINT twenty_five_twenty_idcall_fkey FOREIGN KEY (idcall) REFERENCES public.calls(idc);


-- Completed on 2024-06-10 11:16:02

--
-- PostgreSQL database dump complete
--

