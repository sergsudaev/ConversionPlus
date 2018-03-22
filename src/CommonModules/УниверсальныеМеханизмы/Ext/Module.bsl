﻿
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ РАБОТЫ С НАСТРОЙКАМИ

#Если Клиент Тогда

Функция ВосстановлениеНастроек(СтруктураНастройки) Экспорт
	
	ФормаУправленияНастройками = РегистрыСведений.СохраненныеНастройки.ПолучитьФорму("ФормаУправленияНастройками");
	ФормаУправленияНастройками.мВосстановлениеНастройки = Истина;
	ФормаУправленияНастройками.мСтруктураНастройки = СтруктураНастройки;
	
	Результат = ФормаУправленияНастройками.ОткрытьМодально();
	СтруктураНастройки = ФормаУправленияНастройками.мСтруктураНастройки;
	Возврат Результат;
	
КонецФункции // ВосстановитьНастройки()

Функция СохранениеНастроек(СтруктураНастройки) Экспорт
	
	ФормаУправленияНастройками = РегистрыСведений.СохраненныеНастройки.ПолучитьФорму("ФормаУправленияНастройками");
	ФормаУправленияНастройками.мВосстановлениеНастройки = Ложь;
	ФормаУправленияНастройками.мСтруктураНастройки = СтруктураНастройки;
	
	Результат = ФормаУправленияНастройками.ОткрытьМодально();
	СтруктураНастройки = ФормаУправленияНастройками.мСтруктураНастройки;
	Возврат Результат;
	
КонецФункции // СохранитьНастройки()

#КонецЕсли

Функция ПолучитьНастройку(СтруктураНастройки) Экспорт
	
	Если ТипЗнч(СтруктураНастройки) <> Тип("Структура") Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	СохраненныеНастройки.Пользователь,
	|	СохраненныеНастройки.ИмяОбъекта,
	|	СохраненныеНастройки.НаименованиеНастройки КАК НаименованиеНастройки,
	|	СохраненныеНастройки.СохраненнаяНастройка,
	|	СохраненныеНастройки.ИспользоватьПриОткрытии,
	|	СохраненныеНастройки.СохранятьАвтоматически
	|ИЗ
	|	РегистрСведений.СохраненныеНастройки КАК СохраненныеНастройки
	|ГДЕ
	|	СохраненныеНастройки.ИмяОбъекта = &ИмяОбъекта
	|	И СохраненныеНастройки.Пользователь = &Пользователь
	|	И СохраненныеНастройки.НаименованиеНастройки = &НаименованиеНастройки");
	
	Если СтруктураНастройки.Свойство("Пользователь") = Ложь ИЛИ НЕ ЗначениеЗаполнено(СтруктураНастройки.Пользователь) Тогда
					
		Запрос.УстановитьПараметр("Пользователь", ПараметрыСеанса.ТекущийПользователь);
					
	Иначе
					
		Запрос.УстановитьПараметр("Пользователь", СтруктураНастройки.Пользователь);
					
	КонецЕсли;
		
	Запрос.УстановитьПараметр("ИмяОбъекта", СтруктураНастройки.ИмяОбъекта);
	Запрос.УстановитьПараметр("НаименованиеНастройки", СтруктураНастройки.НаименованиеНастройки);
	
	РезультатЗапроса = Запрос.Выполнить();
		
	Если РезультатЗапроса.Пустой() Тогда
			
		Возврат Ложь;
			
	Иначе
			
		ВыборкаИзРезультатаЗапроса = РезультатЗапроса.Выбрать();
		ВыборкаИзРезультатаЗапроса.Следующий();
		
		СтруктураНастройки.Вставить("СохраненнаяНастройка", ВыборкаИзРезультатаЗапроса.СохраненнаяНастройка.Получить());
		СтруктураНастройки.Вставить("ИспользоватьПриОткрытии", ВыборкаИзРезультатаЗапроса.ИспользоватьПриОткрытии);
		СтруктураНастройки.Вставить("СохранятьАвтоматически", ВыборкаИзРезультатаЗапроса.СохранятьАвтоматически);
		
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ПолучитьНастройку()

Функция ПолучитьНастройки(СтруктураНастройки, ПолучитьНастройкиВсехПользователей = Ложь, ПолучитьГрупповыеНастройки = Ложь, ПолучитьОбщиеНастройки = Ложь) Экспорт
	
	Если ТипЗнч(СтруктураНастройки) <> Тип("Структура") Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	СохраненныеНастройки.Пользователь,
	|	СохраненныеНастройки.ИмяОбъекта,
	|	СохраненныеНастройки.НаименованиеНастройки КАК НаименованиеНастройки,
	|	СохраненныеНастройки.СохраненнаяНастройка,
	|	СохраненныеНастройки.ИспользоватьПриОткрытии,
	|	СохраненныеНастройки.СохранятьАвтоматически,
	|	0 КАК ВидНастройки
	|ИЗ
	|	РегистрСведений.СохраненныеНастройки КАК СохраненныеНастройки
	|ГДЕ
	|	СохраненныеНастройки.ИмяОбъекта = &ИмяОбъекта
	|	И СохраненныеНастройки.Пользователь = &Пользователь
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СохраненныеНастройки.Пользователь,
	|	СохраненныеНастройки.ИмяОбъекта,
	|	СохраненныеНастройки.НаименованиеНастройки,
	|	СохраненныеНастройки.СохраненнаяНастройка,
	|	СохраненныеНастройки.ИспользоватьПриОткрытии,
	|	СохраненныеНастройки.СохранятьАвтоматически,
	|	1
	|ИЗ
	|	РегистрСведений.СохраненныеНастройки КАК СохраненныеНастройки
	|ГДЕ
	|	СохраненныеНастройки.ИмяОбъекта = &ИмяОбъекта
	|	И СохраненныеНастройки.Пользователь <> &Пользователь
	|	И СохраненныеНастройки.Пользователь ССЫЛКА Справочник.Пользователи
	|	И &НастройкиВсехПользователей = ИСТИНА
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	//|ВЫБРАТЬ
	//|	СохраненныеНастройки.Пользователь,
	//|	СохраненныеНастройки.ИмяОбъекта,
	//|	СохраненныеНастройки.НаименованиеНастройки,
	//|	СохраненныеНастройки.СохраненнаяНастройка,
	//|	СохраненныеНастройки.ИспользоватьПриОткрытии,
	//|	СохраненныеНастройки.СохранятьАвтоматически,
	//|	2
	//|ИЗ
	//|	РегистрСведений.СохраненныеНастройки КАК СохраненныеНастройки
	//|ГДЕ
	//|	СохраненныеНастройки.ИмяОбъекта = &ИмяОбъекта
	//|	И ВЫРАЗИТЬ(СохраненныеНастройки.Пользователь КАК Справочник.ГруппыПользователей).ПользователиГруппы.Пользователь = &Пользователь
	//|	И &ГрупповыеНастройки = ИСТИНА
	//|
	//|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СохраненныеНастройки.Пользователь,
	|	СохраненныеНастройки.ИмяОбъекта,
	|	СохраненныеНастройки.НаименованиеНастройки,
	|	СохраненныеНастройки.СохраненнаяНастройка,
	|	СохраненныеНастройки.ИспользоватьПриОткрытии,
	|	СохраненныеНастройки.СохранятьАвтоматически,
	|	3
	|ИЗ
	|	РегистрСведений.СохраненныеНастройки КАК СохраненныеНастройки
	|ГДЕ
	|	СохраненныеНастройки.ИмяОбъекта = &ИмяОбъекта
	|	И СохраненныеНастройки.Пользователь = НЕОПРЕДЕЛЕНО
	|	И &ОбщиеНастройки = ИСТИНА
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВидНастройки,
	|	НаименованиеНастройки");
			
	Если СтруктураНастройки.Свойство("Пользователь") = Ложь ИЛИ НЕ ЗначениеЗаполнено(СтруктураНастройки.Пользователь) Тогда
					
		Запрос.УстановитьПараметр("Пользователь", ПараметрыСеанса.ТекущийПользователь);
					
	Иначе
					
		Запрос.УстановитьПараметр("Пользователь", СтруктураНастройки.Пользователь);
					
	КонецЕсли;
		
	Запрос.УстановитьПараметр("ИмяОбъекта", СтруктураНастройки.ИмяОбъекта);
	Запрос.УстановитьПараметр("НастройкиВсехПользователей", ПолучитьНастройкиВсехПользователей);
	Запрос.УстановитьПараметр("ГрупповыеНастройки", ПолучитьГрупповыеНастройки);
	Запрос.УстановитьПараметр("ОбщиеНастройки", ПолучитьОбщиеНастройки);
	
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции // ПолучитьНастройки()
	
Функция ПолучитьНастройкуИспользоватьПриОткрытии(СтруктураНастройки) Экспорт
	
	Если ТипЗнч(СтруктураНастройки) <> Тип("Структура") Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ВложенныйЗапрос.НаименованиеНастройки КАК НаименованиеНастройки,
	|	ВложенныйЗапрос.СохраненнаяНастройка КАК СохраненнаяНастройка,
	|	ВложенныйЗапрос.СохранятьАвтоматически КАК СохранятьАвтоматически
	|ИЗ
	|	(ВЫБРАТЬ ПЕРВЫЕ 1
	|		СохраненныеНастройки.НаименованиеНастройки КАК НаименованиеНастройки,
	|		СохраненныеНастройки.СохраненнаяНастройка КАК СохраненнаяНастройка,
	|		СохраненныеНастройки.СохранятьАвтоматически КАК СохранятьАвтоматически,
	|		0 КАК ВидНастройки
	|	ИЗ
	|		РегистрСведений.СохраненныеНастройки КАК СохраненныеНастройки
	|	ГДЕ
	|		СохраненныеНастройки.ИмяОбъекта = &ИмяОбъекта
	|		И СохраненныеНастройки.ИспользоватьПриОткрытии = ИСТИНА
	|		И СохраненныеНастройки.Пользователь = &Пользователь
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	//|	ВЫБРАТЬ ПЕРВЫЕ 1
	//|		СохраненныеНастройки.НаименованиеНастройки,
	//|		СохраненныеНастройки.СохраненнаяНастройка,
	//|		СохраненныеНастройки.СохранятьАвтоматически,
	//|		1
	//|	ИЗ
	//|		РегистрСведений.СохраненныеНастройки КАК СохраненныеНастройки
	//|	ГДЕ
	//|		СохраненныеНастройки.ИмяОбъекта = &ИмяОбъекта
	//|		И СохраненныеНастройки.ИспользоватьПриОткрытии = ИСТИНА
	//|		И ВЫРАЗИТЬ(СохраненныеНастройки.Пользователь КАК Справочник.ГруппыПользователей).ПользователиГруппы.Пользователь = &Пользователь
	//|	
	//|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ ПЕРВЫЕ 1
	|		СохраненныеНастройки.НаименованиеНастройки,
	|		СохраненныеНастройки.СохраненнаяНастройка,
	|		СохраненныеНастройки.СохранятьАвтоматически,
	|		2
	|	ИЗ
	|		РегистрСведений.СохраненныеНастройки КАК СохраненныеНастройки
	|	ГДЕ
	|		СохраненныеНастройки.ИмяОбъекта = &ИмяОбъекта
	|		И СохраненныеНастройки.Пользователь = НЕОПРЕДЕЛЕНО
	|		И СохраненныеНастройки.ИспользоватьПриОткрытии = ИСТИНА) КАК ВложенныйЗапрос
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВложенныйЗапрос.ВидНастройки");
		
	Если СтруктураНастройки.Свойство("Пользователь") = Ложь ИЛИ НЕ ЗначениеЗаполнено(СтруктураНастройки.Пользователь) Тогда
					
		Запрос.УстановитьПараметр("Пользователь", ПараметрыСеанса.ТекущийПользователь);
					
	Иначе
					
		Запрос.УстановитьПараметр("Пользователь", СтруктураНастройки.Пользователь);
					
	КонецЕсли;
	
	Запрос.УстановитьПараметр("ИмяОбъекта", СтруктураНастройки.ИмяОбъекта);
		
	РезультатЗапроса = Запрос.Выполнить();
		
	Если РезультатЗапроса.Пустой() Тогда
			
		Возврат Ложь;
			
	Иначе
			
		ВыборкаИзРезультатаЗапроса = РезультатЗапроса.Выбрать();
		ВыборкаИзРезультатаЗапроса.Следующий();
		
		СтруктураНастройки.Вставить("НаименованиеНастройки", ВыборкаИзРезультатаЗапроса.НаименованиеНастройки);
		СтруктураНастройки.Вставить("СохраненнаяНастройка", ВыборкаИзРезультатаЗапроса.СохраненнаяНастройка.Получить());
		СтруктураНастройки.Вставить("ИспользоватьПриОткрытии", Истина);
		СтруктураНастройки.Вставить("СохранятьАвтоматически", ВыборкаИзРезультатаЗапроса.СохранятьАвтоматически);
		
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ПолучитьНастройкуИспользоватьПриОткрытии()


Функция СохранитьНастройку(СтруктураНастройки, СтруктураЗаменяемойНастройки = Неопределено) Экспорт
	
	Если ТипЗнч(СтруктураНастройки) <> Тип("Структура") Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Если СтруктураНастройки.Свойство("ИспользоватьПриОткрытии") И СтруктураНастройки.ИспользоватьПриОткрытии = Истина Тогда
		
		Запрос = Новый Запрос(
		"ВЫБРАТЬ
		|	СохраненныеНастройки.Пользователь,
		|	СохраненныеНастройки.ИмяОбъекта,
		|	СохраненныеНастройки.НаименованиеНастройки
		|ИЗ
		|	РегистрСведений.СохраненныеНастройки КАК СохраненныеНастройки
		|ГДЕ
		|	СохраненныеНастройки.ИспользоватьПриОткрытии = ИСТИНА
		|	И СохраненныеНастройки.Пользователь = &Пользователь
		|	И СохраненныеНастройки.ИмяОбъекта = &ИмяОбъекта
		|	И СохраненныеНастройки.НаименованиеНастройки <> &НаименованиеНастройки");
		
		Запрос.УстановитьПараметр("Пользователь", СтруктураНастройки.Пользователь);
		Запрос.УстановитьПараметр("ИмяОбъекта", СтруктураНастройки.ИмяОбъекта);
		Запрос.УстановитьПараметр("НаименованиеНастройки", СтруктураНастройки.НаименованиеНастройки);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Если РезультатЗапроса.Пустой() = Ложь Тогда
			
			МенеджерЗаписи = РегистрыСведений.СохраненныеНастройки.СоздатьМенеджерЗаписи();
			
			Выборка = РезультатЗапроса.Выбрать();
			
			Пока Выборка.Следующий() Цикл
				
				МенеджерЗаписи.Пользователь = Выборка.Пользователь;
				МенеджерЗаписи.ИмяОбъекта = Выборка.ИмяОбъекта;
				МенеджерЗаписи.НаименованиеНастройки = Выборка.НаименованиеНастройки;
				
				МенеджерЗаписи.Прочитать();
				
				Если МенеджерЗаписи.Выбран() Тогда
					
					МенеджерЗаписи.ИспользоватьПриОткрытии = Ложь;
					МенеджерЗаписи.Записать();
					
				КонецЕсли;
				
			КонецЦикла;
			
		КонецЕсли;
		
	КонецЕсли;
		
	МенеджерЗаписи = РегистрыСведений.СохраненныеНастройки.СоздатьМенеджерЗаписи();
		
	Если СтруктураЗаменяемойНастройки <> Неопределено Тогда
		
		МенеджерЗаписи.Пользователь = СтруктураЗаменяемойНастройки.Пользователь;
		МенеджерЗаписи.ИмяОбъекта = СтруктураЗаменяемойНастройки.ИмяОбъекта;
		МенеджерЗаписи.НаименованиеНастройки = СтруктураЗаменяемойНастройки.НаименованиеНастройки;
		
		МенеджерЗаписи.Прочитать();
		
		Если МенеджерЗаписи.Выбран() Тогда
			
			МенеджерЗаписи.НаименованиеНастройки = СтруктураНастройки.НаименованиеНастройки;
			
			Если СтруктураНастройки.Свойство("СохраненнаяНастройка") Тогда
				
				МенеджерЗаписи.СохраненнаяНастройка = Новый ХранилищеЗначения(СтруктураНастройки.СохраненнаяНастройка, Новый СжатиеДанных(9));
				
			КонецЕсли;
			
			Если СтруктураНастройки.Свойство("ИспользоватьПриОткрытии") Тогда
						
				МенеджерЗаписи.ИспользоватьПриОткрытии = СтруктураНастройки.ИспользоватьПриОткрытии;
						
			КонецЕсли;
					
			Если СтруктураНастройки.Свойство("СохранятьАвтоматически") Тогда
						
				МенеджерЗаписи.СохранятьАвтоматически = СтруктураНастройки.СохранятьАвтоматически;
						
			КонецЕсли;
				
		Иначе
				
			Возврат Ложь;
				
		КонецЕсли;
		
	Иначе
		
		МенеджерЗаписи.Пользователь = СтруктураНастройки.Пользователь;
		МенеджерЗаписи.ИмяОбъекта = СтруктураНастройки.ИмяОбъекта;
		МенеджерЗаписи.НаименованиеНастройки = СтруктураНастройки.НаименованиеНастройки;
		МенеджерЗаписи.СохраненнаяНастройка = Новый ХранилищеЗначения(СтруктураНастройки.СохраненнаяНастройка, Новый СжатиеДанных(9));
		
		Если СтруктураНастройки.Свойство("ИспользоватьПриОткрытии") Тогда
					
			МенеджерЗаписи.ИспользоватьПриОткрытии = СтруктураНастройки.ИспользоватьПриОткрытии;
					
		КонецЕсли;
				
		Если СтруктураНастройки.Свойство("СохранятьАвтоматически") Тогда
					
			МенеджерЗаписи.СохранятьАвтоматически = СтруктураНастройки.СохранятьАвтоматически;
					
		КонецЕсли;
		
	КонецЕсли;
	
	МенеджерЗаписи.Записать();
		
	Возврат Истина;
	
КонецФункции // СохранитьНастройку()

Функция УдалитьНастройку(СтруктураНастройки) Экспорт
	
	Если ТипЗнч(СтруктураНастройки) <> Тип("Структура") Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	МенеджерЗаписи = РегистрыСведений.СохраненныеНастройки.СоздатьМенеджерЗаписи();
		
	МенеджерЗаписи.Пользователь = СтруктураНастройки.Пользователь;
	МенеджерЗаписи.ИмяОбъекта = СтруктураНастройки.ИмяОбъекта;
	МенеджерЗаписи.НаименованиеНастройки = СтруктураНастройки.НаименованиеНастройки;
	
	МенеджерЗаписи.Прочитать();
		
	Если МенеджерЗаписи.Выбран() Тогда
			
		МенеджерЗаписи.Удалить();
			
	Иначе
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // УдалитьНастройку()

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ МЕХАНИЗМА РАБОТЫ С УНИВЕРСАЛЬНЫМ ПОИСКОМ ДАННЫХ
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
 
//Функция возвращает нименование объекта настройки
Функция ПолучитьИмяОбъектаНастройки(ТипОбъектовПоиска) Экспорт
	
	Если ТипОбъектовПоиска = Неопределено Тогда
		Возврат "";
	КонецЕсли;
		
	МетаданныеСправочника = Метаданные.НайтиПоТипу(ТипОбъектовПоиска);	
	
	Возврат "ОбработкаОбъект.УниверсальныйПоискОбъектов.СправочникСсылка." + МетаданныеСправочника.Имя;
	
КонецФункции

#Если Клиент Тогда
	
// Процедура восстанавливает список 10 последних выпавших значений элемента
Процедура ВосстановитьСписокЗначенийУнивер(СписокЗначений, ИмяПараметраДляСохранения = "", СписокЭлементаВизуализации) Экспорт

	Если НЕ ЗначениеЗаполнено(ИмяПараметраДляСохранения) Тогда
		Возврат;
	КонецЕсли;
	
	СписокЗначений.Очистить();
	
	ВосстановленноеЗначение = ВосстановитьЗначение(ИмяПараметраДляСохранения);
	Если ТипЗнч(ВосстановленноеЗначение) = Тип("СписокЗначений") Тогда
		СписокЗначений = ВосстановленноеЗначение;
		СписокЭлементаВизуализации = СписокЗначений.Скопировать();
	КонецЕсли; 
	
КонецПроцедуры

// Процедура добавляет в список последних 10-ти значений элементов
// Параметры :
//		СписокСохраняемыхЗначений - список значений куда нужно поместить очередной элемент
//      ИмяПараметраДляСохранения - под каким именем сохранить значение (если пустая - то ничего не сохраняем)
//      ЭлементСписка			  - выбранный элемент списка
Процедура ДобавитьВСписокЗначенийУнивер(СписокСохраняемыхЗначений, ИмяПараметраДляСохранения = "", ЭлементСписка, 
	Знач ЗначениеПоиска = "") Экспорт

	Если ПустаяСтрока(ЗначениеПоиска) Тогда
		ДобавляемоеЗначение = ЭлементСписка.Значение;
	Иначе
		ДобавляемоеЗначение = ЗначениеПоиска;
    КонецЕсли;
	
	НайденныйЭлемент = СписокСохраняемыхЗначений.НайтиПоЗначению(ДобавляемоеЗначение);
	Если НайденныйЭлемент <> Неопределено Тогда
		СписокСохраняемыхЗначений.Удалить(НайденныйЭлемент);
	КонецЕсли;
	
	СписокСохраняемыхЗначений.Вставить(0, ДобавляемоеЗначение);
	
	Пока СписокСохраняемыхЗначений.Количество() > 10 Цикл
		СписокСохраняемыхЗначений.Удалить(СписокСохраняемыхЗначений.Количество() - 1);
	КонецЦикла;
	
	Если (ЗначениеЗаполнено(ИмяПараметраДляСохранения)) И ТипЗнч(ИмяПараметраДляСохранения) = Тип("Строка") Тогда
		СохранитьЗначение(ИмяПараметраДляСохранения, СписокСохраняемыхЗначений.Скопировать());
	КонецЕсли;
	
	ЭлементСписка.СписокВыбора = СписокСохраняемыхЗначений.Скопировать();

КонецПроцедуры

#КонецЕсли

Функция НапечататьДокументПоУмолчанию(Объект, КоличествоЭкземпляров = 1, НаПринтер = Ложь) Экспорт
	
	Возврат Ложь;
	
КонецФункции
