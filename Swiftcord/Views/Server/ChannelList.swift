//
//  ChannelList.swift
//  Swiftcord
//
//  Created by Vincent on 4/12/22.
//

import SwiftUI
import DiscordKit

struct ChannelList: View, Equatable {
	let channels: [Channel]
	@Binding var selCh: Channel?
	let guild: Guild

	var body: some View {
		List {
			let filteredChannels = channels.filter { $0.parent_id == nil && $0.type != .category }
			if !filteredChannels.isEmpty {
				let sectionHeadline = guild.isDMChannel ? "DIRECT MESSAGES" : "NO CATEGORY"
				Section(header: Text(sectionHeadline)) {
					let channels = filteredChannels.discordSorted()
					ForEach(channels, id: \.id) { channel in
						ChannelButton(channel: channel, guild: guild, selectedCh: $selCh)
							.listRowInsets(.init(top: 1, leading: 0, bottom: 1, trailing: 0))
					}
				}
			}

			let categoryChannels = channels
				.filter { $0.parent_id == nil && $0.type == .category }
				.discordSorted()
			ForEach(categoryChannels, id: \.id) { channel in
				Section(header: Text(channel.name?.uppercased() ?? "")) {
					// Channels in this section
					let channels = channels.filter({ $0.parent_id == channel.id }).discordSorted()
					ForEach(channels, id: \.id) { channel in
						ChannelButton(channel: channel, guild: guild, selectedCh: $selCh)
							.listRowInsets(.init(top: 1, leading: 0, bottom: 1, trailing: 0))
					}
				}
			}
		}
		.padding(.top, 10)
		.listStyle(.sidebar)
		.frame(minWidth: 240, maxHeight: .infinity)
		// this overlay applies a border on the bottom edge of the view
		.overlay(Rectangle().fill(Color(nsColor: .separatorColor)).frame(width: nil, height: 1, alignment: .bottom), alignment: .top)
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.channels == rhs.channels && lhs.selCh == rhs.selCh
	}
}
