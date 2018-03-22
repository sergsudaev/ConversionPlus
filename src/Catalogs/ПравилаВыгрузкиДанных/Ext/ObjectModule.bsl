﻿
Перем мЗагрузкаДанных Экспорт;
Перем мКонтролироватьУникальностьКода Экспорт;

Процедура СгенерироватьУникальныйКод() Экспорт
	
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
		
	Если ПустаяСтрока(Код) Тогда
		Код = глИмяОбъекта(ЭтотОбъект.ОбъектВыборки);
	КонецЕсли;
	
	Код = СформироватьУникальныйКодДляСправочника("ПравилаВыгрузкиДанных", Код, Ссылка, Владелец);		
		
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	
	Если НЕ ЭтоГруппа Тогда
		ТипОбъектаВыборки     = Строка(ОбъектВыборки);
		ИмяПравилаКонвертации = СокрЛП(ПравилоКонвертации);
	КонецЕсли;

	Если ПустаяСтрока(Код) Тогда
		
		СгенерироватьУникальныйКод();
		
	ИначеЕсли мКонтролироватьУникальностьКода Тогда
		
		Код = СформироватьУникальныйКодДляСправочника("ПравилаВыгрузкиДанных", Код, Ссылка, Владелец);
		
	КонецЕсли;
	
	// Проверка корректности имени правила (кода)
	Если Не глИмяКорректно(Код) Тогда
		СообщитьОбОшибке("Не правильно указано имя правила!", Отказ);
		Возврат;
	КонецЕсли;
	
	ПроверитьНаименование();
	
	Если НЕ мЗагрузкаДанных
		И ЭтоНовый()
		И НЕ ЭтоГруппа
		И Родитель.Пустая() 
		И НЕ ПустаяСтрока(ТипОбъектаВыборки) Тогда
		
		УстановитьГруппуПоУмолчаниюДляПВД(ЭтотОбъект);		
				
	КонецЕсли;
	
	Если Порядок = 0 Тогда
		Порядок = ОчереднойПорядок("ПравилаВыгрузкиДанных", Родитель, Владелец);
	КонецЕсли;		
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(Основание)

	Если ТипЗнч(Основание) = Тип("СправочникСсылка.ПравилаКонвертацииОбъектов") Тогда

		Владелец           = Основание.Владелец;
		Код                = Основание.Код;
		Наименование       = Основание.Код;
		ПравилоКонвертации = Основание.Ссылка;
		ОбъектВыборки      = Основание.Источник;
		СпособОтбораДанных = Перечисления.СпособыОтбораДанных.СтандартнаяВыборка;

	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьНаименование()
	
	Если ПустаяСтрока(Наименование) Тогда
		
		Если ЭтоГруппа Тогда
			Наименование = Код;
		Иначе
			Если ЗначениеЗаполнено(ЭтотОбъект.ОбъектВыборки.Синоним) Тогда
				Наименование = ЭтотОбъект.ОбъектВыборки.Синоним;
			Иначе
				Наименование = Код;
			КонецЕсли;
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	ПроверитьНаименование();
	
КонецПроцедуры


мЗагрузкаДанных = Ложь;
мКонтролироватьУникальностьКода = Ложь;