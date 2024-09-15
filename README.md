# DevOps 

## Задача 1

**Условие.** Описать процесс сборки и доставки кода на конечную платформу до работающего приложения на сервере:
- gitflow;
- userflow;
- CI (stages);
- CD (deploy, update, rollback).

### Решение

Прежде чем приступать к описанию процесса сборки и доставки кода на конечную платформу, рассмотрим GitFlow, userflow, CI и CD по отдельности.

**1. GitFlow**
GitFlow - это некоторая методология работы с Git. Она создана для изоляции процессов разработки, тестирования, деплоя и релиза посредством специальной модели ветвления. Автор *Vincent Driessen* опубликовал описание методологии GitFlow в 2010: https://nvie.com/posts/a-successful-git-branching-model/

Думаю, не стоит переписывать перевод содержания статьи, для поставленной задачи достаточно описать в двух словах механизм ветвления и назначение каждой ветки.

Итак, на начальном этапе рассмотрим две ветки:
- main;
- develop.

Первая ветка **main** содержит в себе стабильно работающую версию кода разрабатываемого приложения, код из этой ветки разворачивается в проде, доступ к этой ветке ограничен. Вторая ветка **develop** используется разработчиками и тестировщиками, в ней всегда содержится актуальная версия кода. Под каждую фичу создаётся новая ветка, по окончании работы над фичей ветка мёрджится в **develop**. Тестирование кода можно проводить как в ветке фичи, так и в отдельной одноимённой ветке под тесты, которая ответвляется от **develop**. Все фиксы найденных багов пушатся в **develop**. 

После проверки функционала в **develop** ветке тестировщиками ответвлением от последней создаётся ветка **release**. В ней возможны фиксы багов (изменения после согласуются с **develop**), обновление конфигураций под новую версию релиза, очередные проверки работоспобоности кода, внедрять новые фичи запрещено. Как только релиз готов, он мёрджится в ветку **main**. 

Если в **main** найден баг, создаётся ветка **hotfix**, где вносятся все необходимые изменения в код, проводятся тесты. Когда всё прошло успешно, ветка вновь мёрджится в **main** и **develop**. 

Пример работы GitFlow представлен в виде изображения ниже.
<embed src="https://nvie.com/files/Git-branching-model.pdf" width="600" height="500" type="application/pdf">

В сравнительно небольшом проекте можно обойтись GitFlow без дополнительной автоматизации, тогда тесты, сборка и вывод в прод проводятся вручную. Мёрджи в ветки **develop** и **main** проводятся по pull-requestам. Тогда процесс сборки и доставки кода на конечную платформу до работающего приложения может выглядеть следующим образом (один из сценариев):
1. разработчик ответвляется от **develop** в некоторую ветку **feature**;
2. как только фича готова, разработчик запускает автотесты (положим, что тестировщиков нет, разработчик сам пишет тесты, хоть и это не самая лучшая практика);
3. положим, что тесты прошли успешно, разработчик создаёт pull-request в **develop**;
4. тимлид проводит code-review, положим, что с кодом всё хорошо, тимлид одобряет pull-request;
5. новая фича была последней в спринте, разработка новой версии завершена, за работу приступает релиз-инженер, который создаёт ветку **release**;
6. релиз-инженер ещё раз всё проверяет, меняет конфигурации, возможно деплоит приложение для ручного тестирования, обновляет названия пакетов под новую версию, создаёт тэги и т. п.;
7. если всё ок, релиз-инженер мёрджит ветку **release** в ветку **main**, изменения которой применяются в проде (сервер под прод отдельный, подробности обновления опустим).

**2. Userflow**
Вообще говоря, с userflow ранее не был знаком. В открытых источниках userflow упоминается как некоторая последовательность действий, которую должен проделать пользователь при взаимодействии с некоторым ПО для достижения какой-то цели. Чаще всего последовательность представляется в виде диаграммы. Цель последней предоставить возможность команде разрабатываемого продукта взглянуть на взаимодействие пользователя и приложения глазами пользователя.

Сразу встаёт вопрос о том, кого считать пользователем. Можно рассмотреть два варианта, когда речь идёт:
1. о приложении (продукте), который разрабатывает команда, и пользователе, который будет взаимодействовать с приложением;
2. о инфраструктуре разработки, с которой будут взаимодействовать разработчики, тестировщики, релиз-инженеры и т. д.

Первый вариант актуален для UX/UI-разработчиков, вероятно, автор задания подразумевал не этот случай userflow. Второй же вариант ближе к DevOps, поэтому остановимся на нём.

Ответим на три вопроса:
1. Кто является пользователем?
2. Какова его цель?
3. Какие шаги он должен предпринять для достижения этой цели?

*Источник:* https://habr.com/ru/articles/496760/

Пусть пользователем будет разработчик некоторого приложения. Рассмотрим сценарий, в котором его целью будет пуш фичи, которую он разработал, при этом фича должна собраться и пройти ряд тестов и проверок. Какие же шаги он должен предпринять? 

![Userflow example](img/Userflow.png)

**3. CI**

