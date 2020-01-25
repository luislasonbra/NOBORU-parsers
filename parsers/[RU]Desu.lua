Desu = Parser:new("Desu", "https://desu.me", "RUS", "DESURU")

function Desu:getManga(is_search, link, dest_table)
    local file = {}
	Threads.DownloadStringAsync(link, file, "string", true)
    while file.string == nil do
        coroutine.yield(false)
    end
    local t = dest_table
	local done = true
	local pattern
	if is_search then
		pattern = '<a href="(manga/%S-)".-src="(.-)".-SubTitle">(.-)</div>'
	else
		pattern = 'memberListItem.-<a href="(manga/%S-)".-url%(\'([^\']-)\'%);.-title="([^"]-)"'
	end
	for Link, ImageLink, Name  in file.string:gmatch(pattern) do
		local manga = CreateManga(Name, "/"..Link, self.Link .. ImageLink, self.ID, self.Link .. "/" .. Link)
		if manga then
			t[#t + 1] = manga
			if not is_search then
				done = false
			end
		end
		coroutine.yield(false)
	end
	if done then
		t.NoPages = true
	end
end

function Desu:getPopularManga(page, dest_table)
    Desu:getManga(false, string.format("%s/manga/?order_by=popular&page=%s", self.Link, page), dest_table)
end

function Desu:getLatestManga(page, dest_table)
    Desu:getManga(false, string.format("%s/manga/?page=%s", self.Link, page), dest_table)
end

function Desu:searchManga(search, page, dest_table)
    Desu:getManga(true, string.format("%s/manga/search?q=%s", self.Link, search, page), dest_table)
end

function Desu:getChapters(manga, dest_table)
    local file = {}
	Threads.DownloadStringAsync(self.Link .. manga.Link, file, "string", true)
	while file.string == nil do
		coroutine.yield(false)
	end
	local t = {}
	for Link, Name in file.string:gmatch('<a href="(/manga/%S-)" class="tips Tooltip"[^>]-title="([^>]-)">') do
		t[#t + 1] = {
			Name = Name,
			Link = Link,
			Pages = {},
			Manga = manga
		}
	end
	for i = #t, 1, -1 do
		dest_table[#dest_table + 1] = t[i]
	end
end

function Desu:prepareChapter(chapter, dest_table)
    local file = {}
	Threads.DownloadStringAsync(self.Link .. chapter.Link, file, "string", true)
	while file.string == nil do
		coroutine.yield(false)
    end
    local t = dest_table
    local dir = file.string:match('dir: "\\/\\/([^"]-)",'):gsub("\\/","/") or ""
    local images = file.string:match('images: %[%[(.-)%]%],') or ""
	for link in images:gmatch('"(.-)"') do
		t[#t + 1] = dir .. link
		Console.write("Got " .. t[#t])
	end
end

function Desu:loadChapterPage(link, dest_table)
    dest_table.Link = link
end