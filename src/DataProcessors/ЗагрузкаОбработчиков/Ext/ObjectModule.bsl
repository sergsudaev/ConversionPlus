﻿
////////////////////////////////////////////////////////////////////////////////
// ПЕРЕМЕННЫЕ МОДУЛЯ ОБРАБОТКИ

Перем СписокТиповыхПроцедур Экспорт;	// Массив - Содежит список типовых процедур из макета.
Перем СтруктураПравил;			// Структура - Структура хранения правил конвертации.
Перем ЭтоОбработчикиЗагрузки;	// Булево - Признак типа обработчиков.

////////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС

// Загружает обработчики из строки.
//
// Параметры:
// 	ТекстМодуля - Строка - Содержит текст модуля обработчиков
//
Функция ЗагрузитьОбработчики(ТекстМодуля, ПроверятьКонвертацию = Истина) Экспорт
	
	ТекстИзБуфера = Новый ТекстовыйДокумент;
	ТекстИзБуфера.УстановитьТекст(ТекстМодуля);
	
	Если ПроверятьКонвертацию Тогда
		
		//Для обратной совместимости
		СтрокаИнформации = ТекстИзБуфера.ПолучитьСтроку(2);
		Если Не ЗначениеЗаполнено(СтрокаИнформации) Тогда
			СтрокаИнформации = ТекстИзБуфера.ПолучитьСтроку(4);
		КонецЕсли;
		
		СимволНачалаУИД = Найти(СтрокаИнформации, "{") + 1;
		УИД = Сред(СтрокаИнформации, СимволНачалаУИД, 36);
		
		Попытка
			
			ГуидПравил = Новый УникальныйИдентификатор(УИД);
			
		Исключение
			
			ТекстСообщения = "Неправильный формат модуля обработчиков.";
			
			Возврат ТекстСообщения;
			
		КонецПопытки;
		
		Если Конвертация.УникальныйИдентификатор() =  ГуидПравил Тогда
			
			Если Найти(СтрокаИнформации, "Обработчики выгрузки") = 4 Тогда
				
				ЭтоОбработчикиЗагрузки = Ложь;
				
			ИначеЕсли Найти(СтрокаИнформации, "Обработчики загрузки") = 4 Тогда
				
				ЭтоОбработчикиЗагрузки = Истина;
				
			Иначе
				
				ТекстСообщения = "Неправильный формат заголовка правил.";
				
				Возврат ТекстСообщения;
				
			КонецЕсли;
			
		Иначе
			
			ТекстСообщения = "Текст модуля обработчиков не совпадает с конвертацией.";
			
			Возврат ТекстСообщения;
			
		КонецЕсли;
		
	КонецЕсли;
	
	ПреобразоватьФайлВСтруктуруПравил(ТекстИзБуфера);
	
	НачатьТранзакцию();
	
	Попытка
		
		ОбойтиСтруктуруПравил();
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		Ошибка = ИнформацияОбОшибке();
		ТекстСообщения = "Не удалось загрузить текст отладочного модуля с обработчиками в базу.
		|
		|" + КраткоеПредставлениеОшибки(Ошибка);
		
		Возврат ТекстСообщения;
		
	КонецПопытки;
	
	ТекстСообщения = "Обработчики успешно загружены.";
	
	Возврат ТекстСообщения;
	
КонецФункции

// Загружает интерфейсы обработчиков из текстового документа.
//
// Параметры:
//	ТекстМодуляДокумент - ТекстовыйДокумент - Текстовый документ содержащий модуль обработки
//	ПолучитьТиповыеПроцедуры - Булево - Признак необходимости анализа макета типовых процедур
//	АнализФункций - Булево - Признак необходимости анализа функция
//
Процедура ПрочитатьОбработчики (ТекстМодуляДокумент, ПолучитьТиповыеПроцедуры, АнализФункций = Ложь,
	НачалоПоиска = "ПРОЦЕДУРА", КонецПоиска = "КОНЕЦПРОЦЕДУРЫ") Экспорт
	
	ТекстМодуля = ТекстМодуляДокумент.ПолучитьТекст();
	КоличествоСимволов = 0;
	
	Для НомерСтроки = 1 По ТекстМодуляДокумент.КоличествоСтрок() Цикл
		
		СтрокаДляАнализа = ТекстМодуляДокумент.ПолучитьСтроку(НомерСтроки);
		ДлинаСтроки = СтрДлина(СтрокаДляАнализа) + 1;
		СтрокаДляАнализа = СокрЛП(СтрокаДляАнализа);
		
		Если Лев(СтрокаДляАнализа, 2) = "//" Тогда
			
			КоличествоСимволов = КоличествоСимволов + ДлинаСтроки;
			
			Продолжить;
			
		Иначе
			
			СимволНачалаПроцедуры = Найти(ВРег(СтрокаДляАнализа), НачалоПоиска);
			
			Если СимволНачалаПроцедуры = 1 Тогда
				
				ПроцедураНачало = СимволНачалаПроцедуры + КоличествоСимволов + СтрДлина(НачалоПоиска) + 1;
				
			КонецЕсли;
			
			СимволОкончанияПроцедуры = Найти(ВРег(СтрокаДляАнализа), КонецПоиска);
			
			Если СимволОкончанияПроцедуры <> 0 И ПроцедураНачало <> 0 Тогда
				
				ПроцедураОкончание = СимволОкончанияПроцедуры + КоличествоСимволов - 1;
				ТелоПроцедурыСПараметрами = Сред(ТекстМодуля, ПроцедураНачало, ПроцедураОкончание - ПроцедураНачало + 1);
				ЗагрузитьКодОбработчика(ТелоПроцедурыСПараметрами, ПолучитьТиповыеПроцедуры);
				
			КонецЕсли;
			
		КонецЕсли;
		
		КоличествоСимволов = КоличествоСимволов + ДлинаСтроки;
		
	КонецЦикла;
	
	Если АнализФункций Тогда
		ПрочитатьОбработчики (ТекстМодуляДокумент, ПолучитьТиповыеПроцедуры, Ложь, "ФУНКЦИЯ", "КОНЕЦФУНКЦИИ");
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// Преобразует текстовый документ из буфера в структуру хранения правил.
//
// Параметры
//  ТекстМодуля - ТекстовыйДокумент - Содержит текст модуля отладки
//
Процедура ПреобразоватьФайлВСтруктуруПравил(ТекстМодуля)
	
	ИнициализироватьСтруктуруПравилОбмена();
	
	МакетОбщиеПроцедурыФункции = Обработки.ВыгрузкаОбработчиков.ПолучитьМакет("ОбщиеПроцедурыФункции");
	ПрочитатьОбработчики(МакетОбщиеПроцедурыФункции, Истина);
	УбратьСимволыТабуляцииВНачалеСтроки (ТекстМодуля);
	ПрочитатьОбработчики(ТекстМодуля, Ложь);
	
КонецПроцедуры

// Анализирует структуру правил и вызывает процедуры для записи в базу.
//
Процедура ОбойтиСтруктуруПравил()
	
	ПрименитьОбработчикиКонвертации(СтруктураПравил);
	ПрименитьОбработчики(СтруктураПравил.ПКО, "ПравилаКонвертацииОбъектов");
	ПрименитьОбработчики(СтруктураПравил.ПВД, "ПравилаВыгрузкиДанных");
	ПрименитьОбработчики(СтруктураПравил.ПОД, "ПравилаОчисткиДанных");
	ПрименитьОбработчики(СтруктураПравил.Параметры, "Параметры");
	ПрименитьОбработчикиПКС();
	ПрименитьОбработчикиАлгоритмы(СтруктураПравил.Алгоритмы);
	
КонецПроцедуры

// Инициализация структуры правил обмена и списка типовых процедур.
//
Процедура ИнициализироватьСтруктуруПравилОбмена()
	
	СписокТиповыхПроцедур = Новый Массив;
	
	СтруктураКонвертация = Новый Структура;
	ТаблицаПКО = Новый ТаблицаЗначений;
	ТаблицаПКО.Колонки.Добавить("ИмяОбъекта");
	ТаблицаПВД = ТаблицаПКО.Скопировать();
	ТаблицаПОД = ТаблицаПКО.Скопировать();
	ТаблицаПКС = ТаблицаПКО.Скопировать();
	ТаблицаПараметры = ТаблицаПКО.Скопировать();
	ТаблицаАлгоритмы = Новый ТаблицаЗначений;
	ТаблицаАлгоритмы.Колонки.Добавить("Заголовок");
	ТаблицаАлгоритмы.Колонки.Добавить("Параметры");
	ТаблицаАлгоритмы.Колонки.Добавить("ТелоПроцедуры");
	
	СтруктураПравил = Новый Структура;
	СтруктураПравил.Вставить("Конвертация", СтруктураКонвертация);
	СтруктураПравил.Вставить("ПКО", ТаблицаПКО);
	СтруктураПравил.Вставить("ПКС", ТаблицаПКС);
	СтруктураПравил.Вставить("ПВД", ТаблицаПВД);
	СтруктураПравил.Вставить("ПОД", ТаблицаПОД);
	СтруктураПравил.Вставить("Алгоритмы", ТаблицаАлгоритмы);
	СтруктураПравил.Вставить("Параметры", ТаблицаПараметры);
	
КонецПроцедуры

// Разбирает текст процедуры на заголовок, параметры и тело процедуры.
//
// Параметры:
//  ТекстПроцедуры - Строка - Полный текст процедуры
//  ПолучитьТиповыеПроцедуры - Булево - Признак анализа макета типовых процедур
//
Процедура ЗагрузитьКодОбработчика(ТекстПроцедуры, ПолучитьТиповыеПроцедуры)
	
	ОкончаниеПараметров = Найти(ТекстПроцедуры, ")");
	ТелоПроцедуры = СокрЛП(Сред(ТекстПроцедуры, ОкончаниеПараметров + 1));
	
	НачалоПараметров = Найти(ТекстПроцедуры, "(");
	ЗаголовокПроцедуры = СокрЛП(Лев(ТекстПроцедуры, НачалоПараметров - 1));
	ПараметрыПроцедуры = СокрЛП(Сред(ТекстПроцедуры, НачалоПараметров + 1, ОкончаниеПараметров-НачалоПараметров - 1));
	
	Если Найти(ТелоПроцедуры, "Экспорт") = 1 Тогда
		
		ТелоПроцедуры = СокрЛП(Сред(ТелоПроцедуры, 8));
		
	КонецЕсли;
	
	МассивЗаголовка = МассивИмениОбработчика(ЗаголовокПроцедуры);
	
	Если ПолучитьТиповыеПроцедуры Тогда
		
		ПараметрыТиповойПроцедуры = СтрЗаменить(ПараметрыПроцедуры, Символы.ПС, "");
		ПараметрыТиповойПроцедуры = СтрЗаменить(ПараметрыТиповойПроцедуры, Символы.Таб, "");
		СписокТиповыхПроцедур.Добавить(ЗаголовокПроцедуры + "(" + ПараметрыТиповойПроцедуры + ")");
		
		Возврат;
		
	КонецЕсли;
	
	ТипСобытия = МассивЗаголовка[0];
	
	Если ТипСобытия = "Конвертация" Тогда
		
		СтруктураПравил.Конвертация.Вставить(МассивЗаголовка[1], ТелоПроцедуры);
		
	ИначеЕсли ТипСобытия = "ПКО" Тогда
		
		ДобавитьСтрокуВТаблицуПравил(СтруктураПравил.ПКО, МассивЗаголовка, ТелоПроцедуры)
		
	ИначеЕсли ТипСобытия = "ПКС" Или ТипСобытия = "ПКГС" Тогда
		
		ДобавитьСтрокуВТаблицуПКС(СтруктураПравил.ПКС, МассивЗаголовка, ТелоПроцедуры)
		
	ИначеЕсли ТипСобытия = "ПВД" Тогда
		
		ДобавитьСтрокуВТаблицуПравил(СтруктураПравил.ПВД, МассивЗаголовка, ТелоПроцедуры)
		
	ИначеЕсли ТипСобытия = "ПОД" Тогда
		
		ДобавитьСтрокуВТаблицуПравил(СтруктураПравил.ПОД, МассивЗаголовка, ТелоПроцедуры)
		
	ИначеЕсли ТипСобытия = "Параметры" Тогда
		
		ДобавитьСтрокуВТаблицуПравил(СтруктураПравил.Параметры, МассивЗаголовка, ТелоПроцедуры)
		
	Иначе
		
		Если ЭтоНеТиповаяПроцедура(ЗаголовокПроцедуры + "(" + ПараметрыПроцедуры + ")") Тогда
			
			СтрокаАлгоритма = СтруктураПравил.Алгоритмы.Добавить();
			СтрокаАлгоритма.Заголовок = ЗаголовокПроцедуры;
			СтрокаАлгоритма.Параметры = СтрЗаменить(ПараметрыПроцедуры, Символы.ПС, "");
			СтрокаАлгоритма.ТелоПроцедуры = ТелоПроцедуры;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

// Добавляет описание процедуры в таблицу правил.
// 
// Параметры:
//  ТаблицаПравил - Таблица значений - Таблица для загрузки правил
//  МассивИмен - Массив - Содержит элементы заголовка процедуры
//  Тело процедуры - Строка - Тело процедуры
//
Процедура ДобавитьСтрокуВТаблицуПравил(ТаблицаПравил, МассивИмен, ТелоПроцедуры)
	
	КолонкаПравил = ТаблицаПравил.Колонки.Найти(МассивИмен[2]);
	
	Если КолонкаПравил = Неопределено Тогда
		
		КолонкаПравил = ТаблицаПравил.Колонки.Добавить(МассивИмен[2]);
		
	КонецЕсли;
	
	СтрокаПравил = ТаблицаПравил.Найти(МассивИмен[1], "ИмяОбъекта");
	
	Если СтрокаПравил = Неопределено Тогда
		
		СтрокаПравил = ТаблицаПравил.Добавить();
		СтрокаПравил.ИмяОбъекта = МассивИмен[1];
		
	КонецЕсли;
	
	СтрокаПравил[КолонкаПравил.Имя] = ТелоПроцедуры;
	
КонецПроцедуры

// Добавляет строку в таблицу ПКС.
//
Процедура ДобавитьСтрокуВТаблицуПКС(ТаблицаПравил, МассивИмен, ТелоПроцедуры)
	
	КолонкаПравил = ТаблицаПравил.Колонки.Найти(МассивИмен[2]);
	
	Если КолонкаПравил = Неопределено Тогда
		
		КолонкаПравил = ТаблицаПравил.Колонки.Добавить(МассивИмен[2]);
		
	КонецЕсли;
	
	СтрокаПравил = ТаблицаПравил.Найти(МассивИмен[1] + "_" + МассивИмен[3], "ИмяОбъекта");
	
	Если СтрокаПравил = Неопределено Тогда
		
		СтрокаПравил = ТаблицаПравил.Добавить();
		СтрокаПравил.ИмяОбъекта = МассивИмен[1] + "_" + МассивИмен[3];
		
	КонецЕсли;
	
	СтрокаПравил[КолонкаПравил.Имя] = ТелоПроцедуры;
	
КонецПроцедуры

// Загружает в базу глобальные обработчики.
//
Процедура ПрименитьОбработчикиКонвертации(ПравилаОбмена)
	
	ОбъектИзменен = Ложь;
	ГлобальныеОбработчики = Конвертация.ПолучитьОбъект();
	
	Для Каждого Обработчик Из ПравилаОбмена.Конвертация Цикл
		
		ИзмененныйОбработчик = ИзмененныйВызовАлгоритмов(Обработчик.Значение, ПравилаОбмена.Алгоритмы);
		
		Если ГлобальныеОбработчики["Алгоритм" + Обработчик.Ключ] <> ИзмененныйОбработчик Тогда
			
			ГлобальныеОбработчики["Алгоритм" + Обработчик.Ключ] = ИзмененныйОбработчик;
			ОбъектИзменен = Истина;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если ОбъектИзменен Тогда
		
		ГлобальныеОбработчики.Записать();
		
	КонецЕсли;
	
КонецПроцедуры

// Загружает в базу правила ПОД, ПВД, ПКО, Параметры.
//
Процедура ПрименитьОбработчики(ТаблицаПравил, ИмяСправочника)
	
	Для Каждого СтрокаПравил из ТаблицаПравил Цикл
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	СправочникПравила.Ссылка Как Ссылка
		|ИЗ
		|	Справочник." + ИмяСправочника + " КАК СправочникПравила
		|ГДЕ
		|	СправочникПравила.Владелец = &Конвертация
		|	И СправочникПравила.Код = &Код";
		
		Запрос.УстановитьПараметр("Конвертация", Конвертация);
		Запрос.УстановитьПараметр("Код", СтрокаПравил.ИмяОбъекта);
		
		Результат = Запрос.Выполнить();
		
		Если Не Результат.Пустой() Тогда
			
			ВыборкаПравил = Результат.Выбрать();
			ВыборкаПравил.Следующий();
			
			ОбъектПравил = ВыборкаПравил.Ссылка.ПолучитьОбъект();
			ОбъектИзменен = Ложь;
			
			Для Каждого КолонкаПравил Из ТаблицаПравил.Колонки Цикл
				
				Если КолонкаПравил.Имя = "ИмяОбъекта" Или СтрокаПравил[КолонкаПравил.Имя] = Неопределено
					Или ОбъектПравил["Алгоритм" + КолонкаПравил.Имя] = Null Тогда
					
					Продолжить;
					
				КонецЕсли;
				
				ИзмененныйОбработчик = ИзмененныйВызовАлгоритмов(СтрокаПравил[КолонкаПравил.Имя], СтруктураПравил.Алгоритмы);
				
				Если ОбъектПравил["Алгоритм" + КолонкаПравил.Имя] <> ИзмененныйОбработчик Тогда
					
					ОбъектПравил["Алгоритм" + КолонкаПравил.Имя] = ИзмененныйОбработчик;
					ОбъектИзменен = Истина;
					
				КонецЕсли;
				
			КонецЦикла;
			
			Если ОбъектИзменен Тогда
				
				ОбъектПравил.Записать();
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Загружает правила ПКС и ПКГС.
//
Процедура ПрименитьОбработчикиПКС()
	
	Для Каждого СтрокаПравил Из СтруктураПравил.ПКС Цикл
		
		ПозицияРазделителя = ПоследнийРазделитель(СтрокаПравил.ИмяОбъекта, "_");
		КодПКО = Лев(СтрокаПравил.ИмяОбъекта, ПозицияРазделителя - 1);
		КодПКС = Число(Прав(СтрокаПравил.ИмяОбъекта, СтрДлина(СтрокаПравил.ИмяОбъекта) - ПозицияРазделителя));
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	ПКС.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ПравилаКонвертацииСвойств КАК ПКС
		|ГДЕ
		|	ПКС.Владелец.Владелец = &Конвертация
		|	И ПКС.Код = &Код
		|	И ПКС.Владелец.Код = &ПКО";
		
		Запрос.УстановитьПараметр("Конвертация", Конвертация);
		Запрос.УстановитьПараметр("Код", КодПКС);
		Запрос.УстановитьПараметр("ПКО", КодПКО);
		
		Результат = Запрос.Выполнить();
		
		Если Не Результат.Пустой() Тогда
			
			ВыборкаПравил = Результат.Выбрать();
			ВыборкаПравил.Следующий();
			
			ОбъектПравил = ВыборкаПравил.Ссылка.ПолучитьОбъект();
			ОбъектИзменен = Ложь;
			
			Для Каждого КолонкаПравил Из СтруктураПравил.ПКС.Колонки Цикл
				
				Если КолонкаПравил.Имя = "ИмяОбъекта" Или СтрокаПравил[КолонкаПравил.Имя] = Неопределено Тогда
					
					Продолжить;
					
				КонецЕсли;
				
				ИзмененныйОбработчик = ИзмененныйВызовАлгоритмов(СтрокаПравил[КолонкаПравил.Имя], СтруктураПравил.Алгоритмы);
				
				Если ОбъектПравил["Алгоритм" + КолонкаПравил.Имя] <> ИзмененныйОбработчик Тогда
					
					ОбъектПравил["Алгоритм" + КолонкаПравил.Имя] = ИзмененныйОбработчик;
					ОбъектИзменен = Истина;
					
				КонецЕсли;
				
			КонецЦикла;
			
			Если ОбъектИзменен Тогда
				
				ОбъектПравил.Записать();
				
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Загружает правила алгоритмов.
//
Процедура ПрименитьОбработчикиАлгоритмы(ТаблицаПравил)
	
	Для Каждого СтрокаПравил из ТаблицаПравил Цикл
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		|	Алгоритмы.Ссылка Как Ссылка
		|ИЗ
		|	Справочник.Алгоритмы КАК Алгоритмы
		|ГДЕ
		|	Алгоритмы.Владелец = &Конвертация
		|	И Алгоритмы.Код = &Код";
		
		Запрос.УстановитьПараметр("Конвертация", Конвертация);
		Запрос.УстановитьПараметр("Код", СтрокаПравил.Заголовок);
		
		ВыборкаПравил = Запрос.Выполнить().Выбрать();
		
		Если ВыборкаПравил.Следующий() Тогда
			
			ОбъектПравил = ВыборкаПравил.Ссылка.ПолучитьОбъект();
			ОбъектИзменен = Ложь;
			
			Если ОбъектПравил.Алгоритм <> СтрокаПравил.ТелоПроцедуры Или ОбъектПравил.Параметры <> СтрокаПравил.Параметры Тогда
				
				ОбъектПравил.Алгоритм = СтрокаПравил.ТелоПроцедуры;
				ОбъектПравил.Параметры = СтрокаПравил.Параметры;
				ОбъектИзменен = Истина;
				
			КонецЕсли;
			
		Иначе
			
			ОбъектПравил = Справочники.Алгоритмы.СоздатьЭлемент();
			ОбъектПравил.Владелец = Конвертация;
			ОбъектПравил.Код = СтрокаПравил.Заголовок;
			ОбъектПравил.ИспользуетсяПриЗагрузке = ЭтоОбработчикиЗагрузки;
			ОбъектПравил.Алгоритм = СтрокаПравил.ТелоПроцедуры; 
			ОбъектПравил.Параметры = СтрокаПравил.Параметры;
			ОбъектИзменен = Истина;
			
		КонецЕсли;
		
		Если ОбъектИзменен Тогда
			
			ОбъектПравил.Записать();
			
		КонецЕсли;
		
	КонецЦикла;
	
	УдалитьОтсутствующиеАлгоритмы(ТаблицаПравил.ВыгрузитьКолонку("Заголовок"));
	
КонецПроцедуры

// Помечает на удаление алгоритмы, которые были удалены из кода .
//
// Параметры:
//  АлгоритмыВФайле - Массив - Список имен алгоритмов, содержащихся в загружаемом модуле  
//
Процедура УдалитьОтсутствующиеАлгоритмы(АлгоритмыВФайле)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	Алгоритмы.Ссылка,
	               |	Алгоритмы.Код
	               |ИЗ
	               |	Справочник.Алгоритмы КАК Алгоритмы
	               |ГДЕ
	               |	Алгоритмы.Владелец = &Конвертация
	               |	И Алгоритмы.ЭтоГруппа = ЛОЖЬ
	               |	И Алгоритмы.ИспользуетсяПриЗагрузке = &ИспользуетсяПриЗагрузке
	               |	И Алгоритмы.Код НЕ В (&АлгоритмыВФайле)";
	
	Запрос.УстановитьПараметр("Конвертация", Конвертация);
	Запрос.УстановитьПараметр("ИспользуетсяПриЗагрузке", ЭтоОбработчикиЗагрузки);
	Запрос.УстановитьПараметр("АлгоритмыВФайле", АлгоритмыВФайле);
	
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
			Алгоритм = Выборка.Ссылка.ПолучитьОбъект();
			Алгоритм.УстановитьПометкуУдаления(Истина);
			
	КонецЦикла;
	
КонецПроцедуры

// Убирает символы табуляции в начале каждой строки.
//
Процедура УбратьСимволыТабуляцииВНачалеСтроки (ТекстДляАнализа)
	
	Для ИндексСтроки = 1 По ТекстДляАнализа.КоличествоСтрок() Цикл
		
		СтрокаАнализа = ТекстДляАнализа.ПолучитьСтроку(ИндексСтроки);
		
		Если Лев(СтрокаАнализа, 1) = Символы.Таб Тогда
			
			СтрокаАнализа = Прав(СтрокаАнализа, СтрДлина(СтрокаАнализа) - 1);
			ТекстДляАнализа.ЗаменитьСтроку(ИндексСтроки, СтрокаАнализа);
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Проверяет процедуру на принадлежность к предопределенным.
//
Функция ЭтоНеТиповаяПроцедура(ИмяПроцедуры)
	
	НеТиповая = Ложь;
	
	ИмяПроцедуры = СтрЗаменить(ИмяПроцедуры, Символы.ПС, "");
	ИмяПроцедуры = СтрЗаменить(ИмяПроцедуры, Символы.Таб, "");
	
	Если СписокТиповыхПроцедур.Найти(ИмяПроцедуры) = Неопределено Тогда
		
		НеТиповая = Истина;
		
	КонецЕсли;
	
	Возврат НеТиповая;
	
КонецФункции

// Заменяет вызов процедур алгоритмов конструкцией "Выполнить(Алгоритмы.ИмяАлгоритма)". 
//
Функция ИзмененныйВызовАлгоритмов(ВходнаяСтрока, ТаблицаАлгоритмов)
	
	Если ПустаяСтрока(ВходнаяСтрока) Тогда
		
		Возврат ВходнаяСтрока;
		
	КонецЕсли;
	
	ИзмененнаяСтрока = ВходнаяСтрока;
	
	Для Каждого СтрокаАлгоритма Из ТаблицаАлгоритмов Цикл
		
		СтрокаПоиска = СтрокаАлгоритма.Заголовок;
		ПозицияЗаголовка = Найти(ИзмененнаяСтрока, СтрокаПоиска);
		
		Если ПозицияЗаголовка <> 0 Тогда
			
			ПозицияПоиска = ПозицияЗаголовка + СтрДлина(СтрокаПоиска);
			
			Пока Истина Цикл
				
				Если Сред(ИзмененнаяСтрока, ПозицияПоиска, 1) = "(" Тогда
					
					СимволНачалаПараметров = ПозицияПоиска;
					
				ИначеЕсли Сред(ИзмененнаяСтрока, ПозицияПоиска, 1) = ")" Тогда
					
					СимволОкончанияПараметров = ПозицияПоиска; 
					
					Прервать;
					
				КонецЕсли;
				
				ПозицияПоиска = ПозицияПоиска + 1;
				
			КонецЦикла;
			
			РазмерИмениАлгоритма = СимволОкончанияПараметров - ПозицияЗаголовка + 1;
			СтрокаДляЗамены = Сред(ИзмененнаяСтрока, ПозицияЗаголовка, РазмерИмениАлгоритма);
			СтрокаЗамены = "Выполнить(Алгоритмы." + СтрокаАлгоритма.Заголовок + ")";
			ИзмененнаяСтрока = СтрЗаменить(ИзмененнаяСтрока, СтрокаДляЗамены, СтрокаЗамены);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ИзмененнаяСтрока;
	
КонецФункции

// Получает позицию последнего разделителя в строке.
//
Функция ПоследнийРазделитель(СтрокаСРазделителем, Разделитель = "_")
	
	ДлинаСтроки = СтрДлина(СтрокаСРазделителем);
	
	Пока ДлинаСтроки > 0 Цикл
		
		Если Сред(СтрокаСРазделителем, ДлинаСтроки, 1) = Разделитель Тогда
			
			Возврат ДлинаСтроки; 
			
		КонецЕсли;
		
		ДлинаСтроки = ДлинаСтроки - 1;
		
	КонецЦикла;
	
КонецФункции

// Разбирает строку в массив подстрок в зависимости от типа правила.
//
Функция МассивИмениОбработчика(Строка, Разделитель = "_")
	
	Стр = Строка;
	МассивСтрок = Новый Массив();
	ДлинаРазделителя = СтрДлина(Разделитель);
	
	Пока Истина Цикл
		
		Поз = Найти(Стр, Разделитель);
		
		Если Поз = 0 Тогда
			
			МассивСтрок.Добавить(Стр);
			Прервать;
			
		КонецЕсли;
		
		МассивСтрок.Добавить(Лев(Стр, Поз - 1));
		Стр = Сред(Стр, Поз + ДлинаРазделителя);
		
	КонецЦикла;
	
	РазмерМассива = МассивСтрок.Количество();
	
	Если МассивСтрок[0] = "ПКС" Тогда
		МассивСтрок[1] = Сред(Строка, 5, МассивСтрок[РазмерМассива - 1]);
		
		Для ИндексМассива = 2 По РазмерМассива - 4 Цикл
			МассивСтрок.Удалить(2);
		КонецЦикла;
		
		МассивСтрок.Удалить(МассивСтрок.Количество() - 1);
		
	ИначеЕсли МассивСтрок[0] = "ПВД" Или МассивСтрок[0] = "Параметры" Или МассивСтрок[0] = "ПКО" Или МассивСтрок[0] = "ПОД" Тогда
		
		ИмяПроцедуры = "";
		
		Для ИндексМассива = 1 По МассивСтрок.Количество() - 2 Цикл
			
			ИмяПроцедуры = ИмяПроцедуры + МассивСтрок[ИндексМассива] + "_";
			
		КонецЦикла;
		
		МассивСтрок[1] = Лев(ИмяПроцедуры, СтрДлина(ИмяПроцедуры)-1);
		
		Для ИндексМассива = 2 По МассивСтрок.Количество() - 2 Цикл
			
			МассивСтрок.Удалить(2);
			
		КонецЦикла;
		
	ИначеЕсли МассивСтрок[0] = "ПКГС" Тогда
		
		МассивСтрок[1] = Сред(Строка, 6, МассивСтрок[РазмерМассива - 1]);
		
		Для ИндексМассива = 2 По РазмерМассива-4 Цикл
			
			МассивСтрок.Удалить(2);
			
		КонецЦикла;
		
		МассивСтрок.Удалить(МассивСтрок.Количество() - 1);
		
	КонецЕсли;
	
	Возврат МассивСтрок;
	
КонецФункции