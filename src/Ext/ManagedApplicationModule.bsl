﻿Процедура глУстановитьПометки(ТекСтрока, ТекстАлгоритма = "", Параметры = Неопределено) Экспорт

	Если НЕ ПустаяСтрока(ТекстАлгоритма) Тогда
        Отказ = Ложь;
		Выполнить(ТекстАлгоритма);
		Если Отказ Тогда
			ТекСтрока.Пометка = 0;
		КонецЕсли;
	КонецЕсли;

	Если ТекСтрока.Строки.Количество() > 0 Тогда
		глУстановитьПометкиПодчиненных(ТекСтрока, ТекстАлгоритма, Параметры);
	КонецЕсли;
	
	глУстановитьПометкиРодителей(ТекСтрока);

КонецПроцедуры // глУстановитьПометки()

// Формирует строковое представление типа для свойства или для описания типов.
//
// Параметры: 
//  Свойство       - Свойство, для которого необходимо получить строковое представление типа.
//  Типы           - Типы, для которых необходимо получить строковое представление.
//
// Возвращаемое значение:
//  Строка, содержащая представление типа.
//
Функция глТипыСвойстваСтрокой(Свойство) Экспорт

    Рез = "";

	Типы = Свойство.Типы;
		
	Для каждого Стр Из Типы Цикл

		ИмяТипа = СокрЛП(Стр.Тип);
		
		Если ИмяТипа = "Строка" Тогда
			
			Если Свойство.КвалификаторыСтроки_Длина = 0 Тогда
				ИмяТипа = ИмяТипа + " (Неогр)";
			Иначе
				Если Свойство.КвалификаторыСтроки_Фиксированная Тогда
					ИмяТипа = ИмяТипа + " (Ф" + Свойство.КвалификаторыСтроки_Длина + ")";
				Иначе
					ИмяТипа = ИмяТипа + " (П" + Свойство.КвалификаторыСтроки_Длина + ")";
				КонецЕсли; 
			КонецЕсли; 
			
		ИначеЕсли ИмяТипа = "Число" Тогда
			
			ИмяТипа = ИмяТипа + " (" + Свойство.КвалификаторыЧисла_Длина + "." + Свойство.КвалификаторыЧисла_Точность + ")";
			
		ИначеЕсли ИмяТипа = "Дата" Тогда
			
			ИмяТипа = Свойство.КвалификаторыДаты_Состав;
			Если ПустаяСтрока(ИмяТипа) Тогда
				
				ИмяТипа = "Дата"; // если не известно что за дата - просто пишем, что дата и все
				
			КонецЕсли;
			
		ИначеЕсли Свойство.ЭтоГруппа Тогда
			ИмяТипа = СтрЗаменить(ИмяТипа, "РегистрСведенийЗапись",		"РегистрСведенийНаборЗаписей");
			ИмяТипа = СтрЗаменить(ИмяТипа, "РегистрНакопленияЗапись",	"РегистрНакопленияНаборЗаписей");
			ИмяТипа = СтрЗаменить(ИмяТипа, "РегистрБухгалтерииЗапись",	"РегистрБухгалтерииНаборЗаписей");
			ИмяТипа = СтрЗаменить(ИмяТипа, "РегистрРасчетаЗапись",		"РегистрРасчетаНаборЗаписей");
		КонецЕсли; 
		
        Рез = Рез + ", " + ИмяТипа;
		
	КонецЦикла; 

	Возврат Прав(Рез, СтрДлина(Рез)-2);
	
КонецФункции // глТипыСвойстваСтрокой() 


// Устанавливает состояние пометки у подчиненных строк строки дерева значений
// в зависимости от пометки текущей строки
//
// Параметры:
//  ТекСтрока      - Строка дерева значений
// 
Процедура глУстановитьПометкиПодчиненных(СтрокаРодитель, ТекстАлгоритма, Параметры) Экспорт

	Пометка     = СтрокаРодитель.Пометка;
	Подчиненные = СтрокаРодитель.Строки;

	Для каждого ТекСтрока из Подчиненные Цикл
		Отказ = Ложь;
		Если НЕ ПустаяСтрока(ТекстАлгоритма) Тогда
			Выполнить(ТекстАлгоритма);
		КонецЕсли;
		Если НЕ Отказ Тогда
			ТекСтрока.Пометка = Пометка;
		КонецЕсли;
		
		Если ТекСтрока.Строки.Количество() > 0 Тогда
			глУстановитьПометкиПодчиненных(ТекСтрока, ТекстАлгоритма, Параметры);
		КонецЕсли;
		
	КонецЦикла;
		
КонецПроцедуры // глУстановитьПометкиПодчиненных()

// Устанавливает состояние пометки у родительских строк строки дерева значений
// в зависимости от пометки текущей строки
//
// Параметры:
//  ТекСтрока      - Строка дерева значений
// 
Процедура глУстановитьПометкиРодителей(Родитель) Экспорт

	Если Родитель = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Пометка = Родитель.Пометка;
	
	Если Родитель.Строки.Количество() Тогда

		НайденыВключенные  = Ложь;
		НайденыВыключенные = Ложь;

		Для каждого Строка из Родитель.Строки Цикл
	        Если Строка.Пометка = 0 Тогда
				НайденыВыключенные = Истина;
			ИначеЕсли Строка.Пометка = 1 Тогда
				НайденыВключенные  = Истина;
			КонецЕсли; 
			Если НайденыВключенные И НайденыВыключенные Тогда
				Прервать;
			КонецЕсли; 
		КонецЦикла;
		
		Если НайденыВключенные И НайденыВыключенные Тогда
			Пометка = 2;
		ИначеЕсли НайденыВключенные И (Не НайденыВыключенные) Тогда
			Пометка = 1;
		ИначеЕсли (Не НайденыВключенные) И НайденыВыключенные Тогда
			Пометка = 0;
		ИначеЕсли (Не НайденыВключенные) И (Не НайденыВыключенные) Тогда
			Пометка = 2;
		КонецЕсли;

	КонецЕсли; 

	Родитель.Пометка = Пометка;
	глУстановитьПометкиРодителей(Родитель.Родитель);
	
КонецПроцедуры // глУстановитьПометкиРодителей()

